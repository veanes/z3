#!/usr/bin/env python3
# ============================================================================
# Generator for multivariable regex-membership SMT-LIB benchmarks.
#
# Each benchmark asks whether a word equation over string variables (with
# REPEATED variables = backreference flavour) is a member of a regular language
# that is a Boolean combination (intersection / complement / union / Kleene) of
# ECMAScript character classes, ranges and small alternations mined from
# C:\git\resharp-node\data\lookarounds.json.
#
# Status is assigned rigorously:
#   * SAT   : a concrete witness is CONSTRUCTED and VERIFIED with Python `re`
#             over the ACTUAL characters (a reduced-alphabet witness lifts to
#             the full alphabet, so this is sound).
#   * UNSAT : only from a CONSTRUCTIVE argument (border-free alternation,
#             parity of an even-occurrence layout, monotone containment, forced
#             adjacency, class conflict, disjoint-range overlap).
#   * UNKNOWN: reserved for deliberately hard shapes with no cheap proof.
#
# Output: gen/*.smt2  and  gen/manifest.csv
# ============================================================================
import os, re, csv, glob

OUT = os.path.dirname(os.path.abspath(__file__))
VAR = ["x", "y", "z", "w"]

# ---------- SMT emission helpers -------------------------------------------
def ch(cp):
    if 0x21 <= cp < 0x7f and cp not in (0x22, 0x5c):
        return '"%s"' % chr(cp)
    return '"\\u{%x}"' % cp

def rng(a, b): return "(re.range %s %s)" % (ch(a), ch(b))
def lit_cp(cp): return "(str.to_re %s)" % ch(cp)
def word(s):   return '(str.to_re "%s")' % s          # ascii words only

def union(*es):
    es = list(es); e = es[-1]
    for a in reversed(es[:-1]):
        e = "(re.union %s %s)" % (a, e)
    return e

def inter(*es):
    es = list(es); e = es[-1]
    for a in reversed(es[:-1]):
        e = "(re.inter %s %s)" % (a, e)
    return e

STAR = "(re.* re.allchar)"
PLUS = "(re.+ re.allchar)"
def notc(cp): return "(re.diff re.allchar %s)" % lit_cp(cp)          # [^c]
def contains(expr): return "(re.++ %s (re.++ %s %s))" % (STAR, expr, STAR)
def comp(expr): return "(re.comp %s)" % expr

def showstr(s):
    return "".join(c if 0x21 <= ord(c) < 0x7f else "\\u{%x}" % ord(c) for c in s)

# ---------- character classes (mined; smt single-char + python one-char) ----
class C:
    def __init__(self, smt, pyre, reps, human, cite):
        self.smt, self.pyre, self.reps, self.human, self.cite = smt, pyre, reps, human, cite
    def plus(self): return "(re.+ %s)" % self.smt
    def star(self): return "(re.* %s)" % self.smt

CLS = {
 "digit": C(rng(0x30,0x39), r"[0-9]", "012", "[0-9]", "[0-9] x3409"),
 "d19":   C(rng(0x31,0x39), r"[1-9]", "12", "[1-9]", "[1-9] x1055"),
 "d04":   C(rng(0x30,0x34), r"[0-4]", "01", "[0-4]", "[0-4] x714"),
 "lower": C(rng(0x61,0x7a), r"[a-z]", "abc", "[a-z]", "[a-z] x1818"),
 "upper": C(rng(0x41,0x5a), r"[A-Z]", "AB", "[A-Z]", "[A-Z] x1676"),
 "alpha": C(union(rng(0x41,0x5a),rng(0x61,0x7a)), r"[A-Za-z]", "Aa", "[A-Za-z]", "[a-zA-Z] x773"),
 "alnum": C(union(rng(0x30,0x39),rng(0x41,0x5a),rng(0x61,0x7a)), r"[A-Za-z0-9]", "0Aa", "[0-9A-Za-z]", "[a-zA-Z0-9] x640"),
 "hex":   C(union(rng(0x30,0x39),rng(0x61,0x66)), r"[0-9a-f]", "0af", "[0-9a-f]", "[0-9a-f] x592"),
 "latinext": C(rng(0xc0,0x24f), "[\u00c0-\u024f]", chr(0xc0)+chr(0x100), "[\\u00C0-\\u024F]", "accented classes e.g. [a\\xE1] x719"),
 "cyr":   C(rng(0x430,0x44f), "[\u0430-\u044f]", chr(0x430)+chr(0x431), "[\\u0430-\\u044F]", "Cyrillic runs in corpus"),
 "cjk":   C(rng(0x4e00,0x9fff), "[\u4e00-\u9fff]", chr(0x4e00)+chr(0x4e01), "[\\u4E00-\\u9FFF]", "CJK ranges"),
 "quote": C(union(lit_cp(0x22),lit_cp(0x27)), "[\"']", '"\'', "[\"']", "[\"'] x979"),
}

# ---------- delimiters / special chars --------------------------------------
DELIM = {"semi":0x3b, "comma":0x2c, "amp":0x26, "slash":0x2f, "under":0x5f, "dash":0x2d}

# ---------- alternations (mined literal word lists) -------------------------
ALTS = {
 "fromofin": ["from","of","in"],
 "boollit":  ["true","false"],
 "boolnull": ["true","false","null"],
 "spectest": ["spec","test"],
 "tskw":     ["keyof","infer","typeof","readonly"],
 "cssfunc":  ["max","min","calc","clamp"],
 "scheme":   ["http","https","ftp"],
 "ordinal":  ["th","nd","st"],
 "method":   ["GET","POST","PUT","HEAD","DELETE"],
 "loglevel": ["debug","info","warn","error"],
 "dow":      ["mon","tue","wed","thu","fri"],
 "unit":     ["px","em","rem","vh","vw"],
}

# ---------- multivariable layouts -------------------------------------------
LAYOUTS = {
 "xyx":     [0,1,0],
 "xyxy":    [0,1,0,1],
 "xxyy":    [0,0,1,1],
 "xyyx":    [0,1,1,0],
 "xyzxyz":  [0,1,2,0,1,2],
 "xyzzyx":  [0,1,2,2,1,0],
 "xyxzyz":  [0,1,0,2,1,2],
 "xxyyzz":  [0,0,1,1,2,2],
 "xyzyxz":  [0,1,2,1,0,2],
 "wxyzwxyz":[0,1,2,3,0,1,2,3],
 "wxyzzyxw":[0,1,2,3,3,2,1,0],
}
def nvars(lay): return max(LAYOUTS[lay]) + 1
def lhs_smt(lay): return "(str.++ %s)" % " ".join(VAR[i] for i in LAYOUTS[lay])
def lhs_py(lay, vals): return "".join(vals[i] for i in LAYOUTS[lay])

# ---------- benchmark record + emitter --------------------------------------
BENCH = []
def add(name, status, diff, family, lay, defs, asserts, header, witness=None, note=""):
    BENCH.append(dict(name=name, status=status, diff=diff, family=family, lay=lay,
                      nvars=nvars(lay), defs=defs, asserts=asserts, header=header,
                      witness=witness, note=note))

def emit(rec):
    L = ["(set-logic ALL)", "(set-info :status %s)" % rec["status"], ";; " + "="*74]
    for h in rec["header"]:
        L.append(";; " + h if h else ";;")
    L.append(";; " + "="*74)
    L.extend(rec["defs"])
    for i in range(rec["nvars"]):
        L.append("(declare-fun %s () String)" % VAR[i])
    L.extend(rec["asserts"])
    L.append("(check-sat)")
    return "\n".join(L) + "\n"

# ============================================================================
# TEMPLATE FAMILIES
# ============================================================================
def border_split(wd):
    for k in range(1, len(wd)//2 + 1):
        if wd[:k] == wd[-k:]:
            return wd[:k], wd[k:len(wd)-k]
    return None

# T1 -- border / overlap over a mined literal alternation (layout xyx)
def T1():
    for key, words in ALTS.items():
        Lsmt = union(*[word(w) for w in words])
        sat = None
        for wd in words:
            bs = border_split(wd)
            if bs:
                sat = (wd, bs); break
        lay = "xyx"
        defs = ["(define-fun alt () (RegEx String)\n  %s)" % Lsmt]
        asserts = ["(assert (str.in_re x %s))" % PLUS,
                   "(assert (str.in_re %s alt))" % lhs_smt(lay)]
        if sat:
            wd,(xb,yb) = sat
            assert re.fullmatch("(?:%s)"%"|".join(words), lhs_py(lay,{0:xb,1:yb}))
            hdr = ["Multivariable membership (generated) -- border/overlap, difficulty L2",
                   "Idiom: keyword alternation guarded by anchors/boundaries (very common).",
                   "  alternation = %s" % " | ".join(words),
                   "Vars: x (x2), y ; layout xyx = x.y.x",
                   "Query: x in Sigma+ ;  x.y.x in ( %s )" % " | ".join(words),
                   "Status: SAT -- '%s' has border '%s' so x=\"%s\", y=\"%s\"." % (wd,xb,xb,yb),
                   "Source: mined (word|word) alternations"]
            add("t01-border-%s-sat"%key, "sat", "L2", "border", lay, defs, asserts, hdr,
                witness="x=%s y=%s"%(xb,yb))
        else:
            hdr = ["Multivariable membership (generated) -- border/overlap, difficulty L2",
                   "Idiom: keyword alternation guarded by anchors/boundaries (very common).",
                   "  alternation = %s" % " | ".join(words),
                   "Vars: x (x2), y ; layout xyx = x.y.x",
                   "Query: x in Sigma+ ;  x.y.x in ( %s )" % " | ".join(words),
                   "Status: UNSAT -- no alternative has a non-empty border (prefix=suffix),",
                   "  so x.y.x with |x|>=1 cannot equal any of them.",
                   "Source: mined (word|word) alternations"]
            add("t01-border-%s-unsat"%key, "unsat", "L2", "border", lay, defs, asserts, hdr)

# T2 -- contains-coupling on a repeated var (class+ AND contains a marker)
def T2():
    for lay in ["xyx","xxyy","xyxy"]:
        for cname in ["hex","digit","lower","alnum","latinext","cyr"]:
            cl = CLS[cname]; c = cl.reps[-1]; cp = ord(c)
            defs = ["(define-fun cls () (RegEx String) %s)" % cl.smt,
                    "(define-fun lang () (RegEx String)\n  %s)" %
                      inter(contains(lit_cp(cp)), "(re.+ cls)")]
            asserts = []
            for i in range(nvars(lay)):
                asserts.append("(assert (str.in_re %s %s))" % (VAR[i], PLUS))
            asserts.append("(assert (str.in_re %s lang))" % lhs_smt(lay))
            vals = {i: c for i in range(nvars(lay))}
            s = lhs_py(lay, vals)
            assert re.fullmatch("%s+"%cl.pyre, s) and (c in s)
            hdr = ["Multivariable membership (generated) -- contains-coupling, difficulty L2",
                   "Idiom: positive look-ahead (?=.*c) intersected with a class run (?=%s+)." % cl.human,
                   "Vars: %s ; layout %s" % (", ".join(VAR[i] for i in range(nvars(lay))), lay),
                   "Query: all vars in Sigma+ ; %s in (Sigma* '%s' Sigma*) & %s+" %
                     (lay, showstr(c), cl.human),
                   "Status: SAT -- witness all vars = '%s' (class member containing the mark)." % showstr(c),
                   "Source: %s ; contains-idiom" % cl.cite]
            add("t02-contains-%s-%s-sat"%(cname,lay), "sat", "L2", "contains", lay, defs, asserts, hdr,
                witness="all='%s'"%showstr(c))

# T3 -- two-sided (start via forward, end via reverse) on the repeated var
def T3():
    pairs = [("upper","digit","lower"),("lower","digit","lower"),("digit","lower","digit"),
             ("latinext","digit","lower"),("upper","cyr","lower"),("hex","upper","lower")]
    for lay in ["xyx","xyyx"]:  # word must both start and end with x
        for sc,ec,mc in pairs:
            s_, e_, m_ = CLS[sc], CLS[ec], CLS[mc]
            defs = ["(define-fun sc () (RegEx String) %s)" % s_.smt,
                    "(define-fun ec () (RegEx String) %s)" % e_.smt]
            Lsmt = "(re.++ sc (re.++ %s ec))" % STAR
            asserts = ["(assert (str.in_re x %s))" % PLUS,
                       "(assert (str.in_re y %s))" % m_.plus(),
                       "(assert (str.in_re %s %s))" % (lhs_smt(lay), Lsmt)]
            xs = s_.reps[0] + e_.reps[0]; ys = m_.reps[0]
            assert re.fullmatch("%s.*%s"%(s_.pyre,e_.pyre), lhs_py(lay,{0:xs,1:ys}), re.S)
            hdr = ["Multivariable membership (generated) -- two-sided context, difficulty L2",
                   "Idiom: token anchored by a start and an end class,",
                   "  e.g. (?<=^)%s ... %s$  (start %s, end %s)." % (s_.human,e_.human,s_.human,e_.human),
                   "Vars: %s ; layout %s" % (", ".join(VAR[i] for i in range(nvars(lay))), lay),
                   "Query: x in Sigma+, y in %s+ ; %s in %s . Sigma* . %s" %
                     (m_.human, lay, s_.human, e_.human),
                   "Status: SAT -- x pinned at both ends (first in %s, last in %s);" % (s_.human,e_.human),
                   "  witness x=\"%s\", y=\"%s\"." % (showstr(xs), showstr(ys)),
                   "Source: %s / %s ; two-sided look-around" % (s_.cite, e_.cite)]
            add("t03-twosided-%s-%s-%s-sat"%(sc,ec,lay), "sat", "L2", "twosided", lay, defs, asserts, hdr,
                witness="x=%s y=%s"%(showstr(xs),showstr(ys)))

# T4 -- bounded / modular length coupling
def T4():
    for cname in ["digit","hex","lower"]:
        for n in [2,4,6]:
            cl = CLS[cname]; lay="xyx"
            defs = ["(define-fun cls () (RegEx String) %s)" % cl.smt]
            asserts = ["(assert (str.in_re x (re.+ cls)))",
                       "(assert (str.in_re y (re.* cls)))",
                       "(assert (str.in_re %s ((_ re.loop %d %d) cls)))" % (lhs_smt(lay), n, n)]
            xs = cl.reps[0]; ys = cl.reps[0]*(n-2)
            assert re.fullmatch("%s{%d}"%(cl.pyre,n), lhs_py(lay,{0:xs,1:ys}))
            hdr = ["Multivariable membership (generated) -- bounded count {%d}, difficulty L1" % n,
                   "Idiom: fixed-width field %s{%d} (codes, ids, colour bodies)." % (cl.human,n),
                   "Vars: x (x2), y ; layout xyx",
                   "Query: x in %s+, y in %s* ; x.y.x in %s{%d}" % (cl.human,cl.human,cl.human,n),
                   "Status: SAT -- 2|x|+|y|=%d ; witness x=\"%s\", y=\"%s\"." % (n,showstr(xs),showstr(ys)),
                   "Source: %s" % cl.cite]
            add("t04-exact-%s-%d-sat"%(cname,n), "sat", "L1", "bounded", lay, defs, asserts, hdr,
                witness="x=%s y=%s"%(showstr(xs),showstr(ys)))
    for cname in ["digit","hex","lower"]:
        for k in [2,3,5]:
            cl = CLS[cname]; lay="xyx"
            defs = ["(define-fun cls () (RegEx String) %s)" % cl.smt]
            asserts = ["(assert (str.in_re x (re.+ cls)))",
                       "(assert (str.in_re y (re.* cls)))",
                       "(assert (str.in_re %s (re.+ ((_ re.loop %d %d) cls))))" % (lhs_smt(lay),k,k)]
            ylen = (k-2) % k
            xs = cl.reps[0]; ys = cl.reps[0]*ylen
            assert re.fullmatch("(?:%s{%d})+"%(cl.pyre,k), lhs_py(lay,{0:xs,1:ys}))
            hdr = ["Multivariable membership (generated) -- modular length (%s{%d})+, difficulty L2" % (cl.human,k),
                   "Idiom: length-modulo look-ahead (?=(%s{%d})+) (grouping / chunking)." % (cl.human,k),
                   "Vars: x (x2), y ; layout xyx",
                   "Query: x in %s+, y in %s* ; x.y.x in (%s{%d})+" % (cl.human,cl.human,cl.human,k),
                   "Status: SAT -- 2|x|+|y| = 0 mod %d ; witness x=\"%s\", y=\"%s\"." % (k,showstr(xs),showstr(ys)),
                   "Source: %s ; counting look-ahead" % cl.cite]
            add("t04-mod-%s-%d-sat"%(cname,k), "sat", "L2", "bounded", lay, defs, asserts, hdr,
                witness="x=%s y=%s"%(showstr(xs),showstr(ys)))

# T5 -- parity UNSAT over an all-even-occurrence layout
def T5():
    even_layouts = ["xyxy","xxyy","xyyx","xyzxyz","xyzzyx","xxyyzz","xyzyxz","wxyzwxyz","wxyzzyxw"]
    combos = [("lower","a"),("digit","0"),("hex","f"),("cyr",chr(0x430))]
    picks = 0
    for lay in even_layouts:
        for cname, c in combos:
            if picks >= 12: return
            cl = CLS[cname]; cp = ord(c)
            nc = notc(cp); Cc = lit_cp(cp)
            # exact "odd number of c":  (nc* c nc* c)* nc* c nc*
            grp  = "(re.++ (re.* %s) (re.++ %s (re.++ (re.* %s) %s)))" % (nc, Cc, nc, Cc)
            tail = "(re.++ (re.* %s) (re.++ %s (re.* %s)))" % (nc, Cc, nc)
            oddC = "(re.++ (re.* %s) %s)" % (grp, tail)
            # verify the language really is "odd number of c" (matches odd, rejects even)
            pe = re.escape(c)
            pyodd = r"(?:[^%s]*%s[^%s]*%s)*[^%s]*%s[^%s]*" % (pe,pe,pe,pe,pe,pe,pe)
            assert re.fullmatch(pyodd, c) and re.fullmatch(pyodd, "z"+c+"z"+c+"z"+c)
            assert not re.fullmatch(pyodd, "") and not re.fullmatch(pyodd, c+c) \
                   and not re.fullmatch(pyodd, "z"+c+"z"+c)
            defs = ["(define-fun cls () (RegEx String) %s)" % cl.smt,
                    "(define-fun oddc () (RegEx String)   ;; odd number of '%s'\n  %s)" % (showstr(c), oddC)]
            asserts = []
            for i in range(nvars(lay)):
                asserts.append("(assert (str.in_re %s (re.+ cls)))" % VAR[i])
            asserts.append("(assert (str.in_re %s oddc))" % lhs_smt(lay))
            hdr = ["Multivariable membership (generated) -- parity contradiction, difficulty L3",
                   "Idiom: parity / counting constraint (odd number of a marker char).",
                   "Vars: %s (each occurs an EVEN number of times) ; layout %s" %
                     (", ".join(VAR[i] for i in range(nvars(lay))), lay),
                   "Query: each var in %s+ ; %s in { odd count of '%s' }" % (cl.human, lay, showstr(c)),
                   "Status: UNSAT -- each variable occurs an even number of times, so the count of",
                   "  any character (incl. '%s') is even; an odd count is impossible." % showstr(c),
                   "Source: %s ; parity look-ahead" % cl.cite]
            add("t05-parity-%s-%s-c%02x-unsat"%(lay,cname,cp), "unsat", "L3", "parity", lay, defs, asserts, hdr)
            picks += 1

# T6 -- forced adjacency UNSAT
def T6():
    adj = [("xxyy",0),("xyyx",1),("xyzzyx",2),("xxyyzz",2),("wxyzzyxw",3)]
    combos = ["digit","lower","hex","cyr"]
    picks=0
    for lay, dvar in adj:
        for cname in combos:
            if picks>=10: return
            cl = CLS[cname]
            forb = comp(contains("((_ re.loop 2 2) %s)" % cl.smt))
            defs = ["(define-fun cls () (RegEx String) %s)" % cl.smt,
                    "(define-fun noadj () (RegEx String)  ;; no two adjacent %s\n  %s)" % (cl.human, forb)]
            asserts = []
            for i in range(nvars(lay)):
                dom = "(re.+ cls)" if i==dvar else PLUS
                asserts.append("(assert (str.in_re %s %s))" % (VAR[i], dom))
            asserts.append("(assert (str.in_re %s noadj))" % lhs_smt(lay))
            dv = VAR[dvar]
            hdr = ["Multivariable membership (generated) -- forced adjacency, difficulty L3",
                   "Idiom: negative look-ahead (?!%s%s) 'no two adjacent %s chars'." % (cl.human,cl.human,cl.human),
                   "Vars: %s ; layout %s (the two %s occurrences are ADJACENT)" %
                     (", ".join(VAR[i] for i in range(nvars(lay))), lay, dv),
                   "Query: %s in %s+ ; %s in ~(Sigma* %s{2} Sigma*)" % (dv,cl.human,lay,cl.human),
                   "Status: UNSAT -- the adjacent %s%s places two %s chars side by side," % (dv,dv,cl.human),
                   "  forbidden by the complement, for every value of %s." % dv,
                   "Source: %s ; negative look-ahead" % cl.cite]
            add("t06-adjacency-%s-%s-unsat"%(lay,cname), "unsat", "L3", "adjacency", lay, defs, asserts, hdr)
            picks+=1

# T7 -- nested complement inside a star (record stream), UNSAT but hard
def T7():
    for dkey, dcp in DELIM.items():
        for bcname in ["lower","digit"]:
            bc = CLS[bcname]; lay="xyx"
            body = inter("(re.* cls)", comp(contains(lit_cp(dcp))))
            rec  = "(re.* (re.++ body %s))" % lit_cp(dcp)
            defs = ["(define-fun cls () (RegEx String) %s)" % bc.smt,
                    "(define-fun body () (RegEx String)  ;; %s chars, no delimiter\n  %s)" % (bc.human, body),
                    "(define-fun rec () (RegEx String)   ;; ( body '%s' )*\n  %s)" % (showstr(chr(dcp)), rec)]
            asserts = ["(assert (str.in_re x %s))" % PLUS,
                       "(assert (str.in_re %s rec))" % lhs_smt(lay),
                       "(assert (str.in_re %s %s))" % (lhs_smt(lay), comp(contains(lit_cp(dcp)))),
                       "(assert (str.in_re %s %s))" % (lhs_smt(lay), PLUS)]
            hdr = ["Multivariable membership (generated) -- nested complement in a star, difficulty L3",
                   "Idiom: record stream ( (?:(?!D)[..])* D )* with a global (?!.*D) 'no delimiter'.",
                   "  delimiter D = '%s'" % showstr(chr(dcp)),
                   "Vars: x (x2), y ; layout xyx",
                   "Query: x in Sigma+ ; x.y.x in ( body '%s' )* & ~(Sigma* '%s' Sigma*) & Sigma+" %
                     (showstr(chr(dcp)), showstr(chr(dcp))),
                   "Status: UNSAT -- every non-empty member of ( body D )* ends with D, but the",
                   "  'no delimiter' complement forbids D; a non-empty word cannot satisfy both.",
                   "Source: %s ; nested negative look-ahead (HARD for the solver)" % bc.cite]
            add("t07-nestedcompl-%s-%s-unsat"%(dkey,bcname), "unsat", "L3", "nested", lay, defs, asserts, hdr)

# T8 -- periodic multivariable membership (SAT; interleaved => hard for nseq)
def T8():
    for u in ["ab","abc","xy","de"]:
        for lay in ["xyxy","xyzxyz","xyxzyz","xyzyxz"]:
            nv = nvars(lay)
            if nv > 3: continue
            defs = ["(define-fun unit () (RegEx String) %s)" % word(u)]
            asserts = []
            for i in range(nv):
                asserts.append("(assert (str.in_re %s %s))" % (VAR[i], PLUS))
            asserts.append("(assert (str.in_re %s (re.+ unit)))" % lhs_smt(lay))
            assert re.fullmatch("(?:%s)+"%re.escape(u), lhs_py(lay,{i:u for i in range(nv)}))
            diff = "L3" if lay in ("xyxzyz","xyzyxz") else "L2"
            hdr = ["Multivariable membership (generated) -- periodic, difficulty %s" % diff,
                   "Idiom: repetition of a fixed unit (u)+ with backreferenced fragments.",
                   "  unit = \"%s\"" % u,
                   "Vars: %s ; layout %s" % (", ".join(VAR[i] for i in range(nv)), lay),
                   "Query: all vars in Sigma+ ; %s in (\"%s\")+" % (lay, u),
                   "Status: SAT -- witness all vars = \"%s\" (word becomes \"%s\" repeated)." % (u,u),
                   "Source: periodic membership (cf. the x.y.x.y in (ab)* word-equation family)"]
            add("t08-periodic-%s-%s-sat"%(u,lay), "sat", diff, "periodic", lay, defs, asserts, hdr,
                witness="all=%s"%u)
    for c1,c2 in [("digit","lower"),("upper","digit"),("hex","hex")]:
        for lay in ["xyxy","xyxzyz"]:
            nv = nvars(lay); a, b = CLS[c1], CLS[c2]
            defs = ["(define-fun pair () (RegEx String) (re.++ %s %s))" % (a.smt, b.smt)]
            asserts = []
            for i in range(nv):
                asserts.append("(assert (str.in_re %s %s))" % (VAR[i], PLUS))
            asserts.append("(assert (str.in_re %s (re.+ pair)))" % lhs_smt(lay))
            us = a.reps[0] + b.reps[0]
            assert re.fullmatch("(?:%s%s)+"%(a.pyre,b.pyre), lhs_py(lay,{i:us for i in range(nv)}))
            diff = "L3" if lay=="xyxzyz" else "L2"
            hdr = ["Multivariable membership (generated) -- periodic pairs, difficulty %s" % diff,
                   "Idiom: stream of typed pairs (%s%s)+ (e.g. digit-letter, hex pairs)." % (a.human,b.human),
                   "Vars: %s ; layout %s" % (", ".join(VAR[i] for i in range(nv)), lay),
                   "Query: all vars in Sigma+ ; %s in (%s%s)+" % (lay, a.human, b.human),
                   "Status: SAT -- witness all vars = \"%s\"." % showstr(us),
                   "Source: %s / %s ; periodic pairs" % (a.cite, b.cite)]
            add("t08-pairs-%s-%s-%s-sat"%(c1,c2,lay), "sat", diff, "periodic", lay, defs, asserts, hdr,
                witness="all=%s"%showstr(us))

# T9 -- class conflict UNSAT (easy)
def T9():
    disj = [("lower","digit"),("digit","lower"),("upper","digit"),("digit","upper"),
            ("cyr","lower"),("latinext","digit"),("cjk","lower")]
    for whole, vc in disj:
        W, V = CLS[whole], CLS[vc]; lay="xyx"
        defs = ["(define-fun whole () (RegEx String) %s)" % W.smt,
                "(define-fun vc () (RegEx String) %s)" % V.smt]
        asserts = ["(assert (str.in_re x (re.+ vc)))",
                   "(assert (str.in_re y %s))" % STAR,
                   "(assert (str.in_re %s (re.+ whole)))" % lhs_smt(lay)]
        hdr = ["Multivariable membership (generated) -- class conflict, difficulty L1",
               "Idiom: a whole-token class %s+ vs a fragment forced into a DISJOINT class %s+." % (W.human,V.human),
               "Vars: x (x2), y ; layout xyx",
               "Query: x in %s+ ; x.y.x in %s+" % (V.human, W.human),
               "Status: UNSAT -- x's characters must be in %s yet also in the disjoint" % W.human,
               "  class %s -- impossible." % V.human,
               "Source: %s / %s" % (W.cite, V.cite)]
        add("t09-conflict-%s-%s-unsat"%(whole,vc), "unsat", "L1", "conflict", lay, defs, asserts, hdr)

# T10 -- disjoint-range border UNSAT (incl. astral ranges)
def T10():
    EMO1=("\\u{1f600}","\\u{1f60f}","[\\u{1F600}-\\u{1F60F}]")
    EMO2=("\\u{1f620}","\\u{1f62f}","[\\u{1F620}-\\u{1F62F}]")
    SURH=("\\u{d800}","\\u{dbff}","[\\uD800-\\uDBFF]")
    SURL=("\\u{dc00}","\\u{dfff}","[\\uDC00-\\uDFFF]")
    def rr(t): return "(re.range \"%s\" \"%s\")" % (t[0],t[1])
    pairs = [(EMO1,EMO2,"emoji"),(SURH,SURL,"surrogate"),
             ((CLS["latinext"].smt,None,CLS["latinext"].human),(CLS["cyr"].smt,None,CLS["cyr"].human),"latinext-cyr"),
             ((CLS["digit"].smt,None,CLS["digit"].human),(CLS["upper"].smt,None,CLS["upper"].human),"digit-upper")]
    for r1,r2,tag in pairs:
        for m in [1,2]:
            e1 = rr(r1) if r1[1] else r1[0]
            e2 = rr(r2) if r2[1] else r2[0]
            lay="xyx"
            defs = ["(define-fun r1 () (RegEx String) %s)" % e1,
                    "(define-fun r2 () (RegEx String) %s)" % e2]
            L = "(re.++ ((_ re.loop %d %d) r1) ((_ re.loop %d %d) r2))" % (m,m,m,m)
            asserts = ["(assert (str.in_re x %s))" % PLUS,
                       "(assert (str.in_re %s %s))" % (lhs_smt(lay), L)]
            hdr = ["Multivariable membership (generated) -- disjoint-range border, difficulty L2",
                   "Idiom: two DISJOINT character ranges concatenated (%s then %s)." % (r1[2], r2[2]),
                   "Vars: x (x2), y ; layout xyx",
                   "Query: x in Sigma+ ; x.y.x in %s{%d} . %s{%d}" % (r1[2],m,r2[2],m),
                   "Status: UNSAT -- writing the word as x.y.x with |x|>=1 forces x's chars into",
                   "  BOTH ranges at once, but the ranges are disjoint.",
                   "Source: mined ranges (incl. astral / surrogate classes)"]
            add("t10-disjoint-%s-m%d-unsat"%(tag,m), "unsat", "L2", "disjoint", lay, defs, asserts, hdr)

# ---------- run all families, verify, write --------------------------------
for T in [T1,T2,T3,T4,T5,T6,T7,T8,T9,T10]:
    T()

for f in glob.glob(os.path.join(OUT, "*.smt2")):
    os.remove(f)

for rec in BENCH:
    with open(os.path.join(OUT, rec["name"] + ".smt2"), "w", encoding="utf-8") as fh:
        fh.write(emit(rec))

with open(os.path.join(OUT,"manifest.csv"),"w",newline="",encoding="utf-8") as fh:
    wtr=csv.writer(fh)
    wtr.writerow(["file","family","layout","nvars","difficulty","status","witness","note"])
    for r in BENCH:
        wtr.writerow([r["name"]+".smt2", r["family"], r["lay"], r["nvars"], r["diff"],
                      r["status"], r["witness"] or "", r["note"]])

from collections import Counter
print("generated", len(BENCH), "benchmarks")
print("by status    :", dict(Counter(r["status"] for r in BENCH)))
print("by difficulty:", dict(Counter(r["diff"] for r in BENCH)))
print("by family    :", dict(Counter(r["family"] for r in BENCH)))
print("by nvars     :", dict(Counter(r["nvars"] for r in BENCH)))
