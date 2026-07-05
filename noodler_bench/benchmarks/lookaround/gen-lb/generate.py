#!/usr/bin/env python3
# ============================================================================
# Generator for HARD lookbehind / nested-lookaround multivariable regex-
# membership SMT-LIB benchmarks that stress the seq_split split algebra.
#
# Motivation (see split-algebra in src/ast/rewriter/seq_split.{h,cpp}):
#   A negative lookbehind at the start of a regex,  (?<!L) R ,  translates to
#       ~(Sigma* . L) . R
#   i.e. a COMPLEMENT concatenated on the RIGHT with a regex R.  In the split
#   algebra sigma this is  rcat(compl(sigma(Sigma* L)), R) , which drives the
#   compl + rcat expansion (the "splitting" path).  More generally:
#       A (?<=L) B  ==  (A cap  Sigma* L ) . B         (positive lookbehind)
#       A (?<!L) B  ==  (A cap ~(Sigma* L)) . B         (negative lookbehind)
#       A (?=M)  B  ==  A . (B cap  M Sigma* )          (positive lookahead)
#       A (?!M)  B  ==  A . (B cap ~(M Sigma* ))         (negative lookahead)
#
# Idioms are mined from C:\git\resharp-node\data\lookarounds.json (42,677 real
# npm regexes; 5,360 with negative lookbehind, 7,955 positive, 1,211 nested).
#
# Variables repeat (backreference flavour); status is assigned rigorously:
#   * SAT   : a concrete witness is CONSTRUCTED and VERIFIED with an exact
#             Brzozowski-derivative membership evaluator over the actual regex
#             algebra (handles intersection / complement / loop).  Deciding a
#             concrete string is alphabet-independent, so the witness is sound.
#   * UNSAT : from a CONSTRUCTIVE argument stated in the header (suffix-class
#             conflict at a forced position), plus a bounded no-witness check.
#
# Output: *.smt2 (prefix l11..l17) and manifest.csv (validate.py adds observed
# columns).  Deterministic; no third-party dependencies.
# ============================================================================
import os, csv, glob
from collections import Counter

OUT = os.path.dirname(os.path.abspath(__file__))

# ---------------------------------------------------------------------------
# Exact regex-membership evaluator (Brzozowski derivatives).  AST tuples:
#   ('eps',) ('bot',) ('any',) ('chr',cp) ('rng',lo,hi) ('word',s)
#   ('cat',a,b) ('alt',a,b) ('and',a,b) ('star',a) ('plus',a) ('comp',a) ('loop',a,n)
# ---------------------------------------------------------------------------
BOT = ('bot',)
def nullable(r):
    t = r[0]
    if t == 'bot': return False
    if t == 'eps': return True
    if t in ('chr','rng','any'): return False
    if t == 'word': return r[1] == ""
    if t == 'cat': return all(nullable(x) for x in r[1:])
    if t == 'alt': return any(nullable(x) for x in r[1:])
    if t == 'and': return all(nullable(x) for x in r[1:])
    if t == 'star': return True
    if t == 'plus': return nullable(r[1])
    if t == 'comp': return not nullable(r[1])
    if t == 'loop': return r[2] == 0 or nullable(r[1])
    raise ValueError(t)
def _cat(a,b):
    if a[0]=='bot' or b[0]=='bot': return BOT
    if a==('eps',) or (a[0]=='word' and a[1]==""): return b
    if b==('eps',) or (b[0]=='word' and b[1]==""): return a
    return ('cat',a,b)
def _alt(a,b):
    if a[0]=='bot': return b
    if b[0]=='bot': return a
    if a==b: return a
    return ('alt',a,b)
def _and(a,b):
    if a[0]=='bot' or b[0]=='bot': return BOT
    if a==b: return a
    return ('and',a,b)
def der(r,cp):
    t = r[0]
    if t in ('bot','eps'): return BOT
    if t == 'chr': return ('eps',) if cp==r[1] else BOT
    if t == 'rng': return ('eps',) if r[1]<=cp<=r[2] else BOT
    if t == 'any': return ('eps',)
    if t == 'word':
        s=r[1]
        return ('word',s[1:]) if (s and ord(s[0])==cp) else BOT
    if t == 'cat':
        head,*rest=r[1:]
        tail=('cat',*rest) if len(rest)>1 else (rest[0] if rest else ('eps',))
        d=_cat(der(head,cp),tail)
        return _alt(d,der(tail,cp)) if nullable(head) else d
    if t == 'alt':
        acc=BOT
        for x in r[1:]: acc=_alt(acc,der(x,cp))
        return acc
    if t == 'and':
        acc=None
        for x in r[1:]:
            d=der(x,cp); acc=d if acc is None else _and(acc,d)
        return acc
    if t == 'star': return _cat(der(r[1],cp), r)
    if t == 'plus': return _cat(der(r[1],cp), ('star',r[1]))
    if t == 'comp': return ('comp',der(r[1],cp))
    if t == 'loop':
        if r[2]==0: return BOT
        return _cat(der(r[1],cp), ('loop',r[1],r[2]-1))
    raise ValueError(t)
def matches(r,s):
    for ch in s: r=der(r,ord(ch))
    return nullable(r)

# ---------------------------------------------------------------------------
# Dual builder: every Re carries its SMT text AND its evaluator AST, so the
# emitted benchmark and the verified regex are guaranteed identical.
# ---------------------------------------------------------------------------
def _esc(s): return s.replace("\\","\\\\").replace('"','\\"')
class Re:
    def __init__(self, smt, ast): self.smt, self.ast = smt, ast
def _bin(op, rs):
    e = rs[-1].smt
    for a in reversed(rs[:-1]): e = "(%s %s %s)" % (op, a.smt, e)
    return e
def _fold(tag, rs):
    e = rs[-1].ast
    for a in reversed(rs[:-1]): e = (tag, a.ast, e)
    return e
A = Re("re.allchar", ('any',))
def rng(a,b): return Re('(re.range "%s" "%s")' % (a,b), ('rng',ord(a),ord(b)))
def word(s):  return Re('(str.to_re "%s")' % _esc(s), ('word',s))
def cat(*rs): return Re(_bin("re.++", rs), _fold('cat', rs))
def alt(*rs): return Re(_bin("re.union", rs), _fold('alt', rs))
def andr(*rs):return Re(_bin("re.inter", rs), _fold('and', rs))
def star(r):  return Re("(re.* %s)" % r.smt, ('star', r.ast))
def plus(r):  return Re("(re.+ %s)" % r.smt, ('plus', r.ast))
def comp(r):  return Re("(re.comp %s)" % r.smt, ('comp', r.ast))
def loop(r,n):return Re("((_ re.loop %d %d) %s)" % (n,n,r.smt), ('loop', r.ast, n))
STAR = star(A)

def nlb(L, R):   return cat(comp(cat(STAR, L)), R)        # ~(Sigma* L) . R   (neg lookbehind)
def contains(r): return cat(STAR, r, STAR)

# ---------------------------------------------------------------------------
# Mined material (with corpus citations).
# ---------------------------------------------------------------------------
CLS = {
 "digit": (rng("0","9"), "[0-9]",   "0", "[0-9] (very common counted field)"),
 "lower": (rng("a","z"), "[a-z]",   "a", "[a-z]"),
 "upper": (rng("A","Z"), "[A-Z]",   "A", "[A-Z]"),
 "hex":   (alt(rng("0","9"),rng("a","f")), "[0-9a-f]", "a", "[0-9a-f] hex bodies"),
}
# negative-lookbehind context words actually seen at the start of corpus regexes
CTX = {
 "cu":   ("cu",   "(?<! cu)bot  -- 'bot' not preceded by 'cu'"),
 "left": ("left", "(?<! left) join  -- SQL join not preceded by 'left'"),
 "in":   ("in",   "(?<! in ){}  -- token not preceded by 'in'"),
 "sub":  ("sub",  "(?<!sub)class  -- 'class' not preceded by 'sub'"),
 "un":   ("un",   "(?<!un)able  -- 'able' not preceded by 'un'"),
}

LAYOUTS = {"xyx":[0,1,0], "xyyx":[0,1,1,0], "xyxy":[0,1,0,1],
           "xyzx":[0,1,2,0], "xyzyx":[0,1,2,1,0]}
def nvars(lay): return max(LAYOUTS[lay])+1
VAR = ["x","y","z","w"]
def lhs_smt(lay): return "(str.++ %s)" % " ".join(VAR[i] for i in LAYOUTS[lay])
def lhs_word(lay, vals): return "".join(vals[i] for i in LAYOUTS[lay])

# ---------------------------------------------------------------------------
# Benchmark record + emitter.
# ---------------------------------------------------------------------------
BENCH = []
def add(name, status, diff, family, lay, defs, asserts, header, witness="", note=""):
    BENCH.append(dict(name=name, status=status, diff=diff, family=family, lay=lay,
                      nvars=nvars(lay), defs=defs, asserts=asserts, header=header,
                      witness=witness, note=note))
def emit(rec):
    L = ["(set-logic ALL)", "(set-info :status %s)" % rec["status"], ";;"+"="*74]
    for h in rec["header"]: L.append(";; "+h if h else ";;")
    L.append(";;"+"="*74)
    L.extend(rec["defs"])
    for i in range(rec["nvars"]): L.append("(declare-fun %s () String)" % VAR[i])
    L.extend(rec["asserts"])
    L.append("(check-sat)")
    return "\n".join(L)+"\n"

# verification helpers ------------------------------------------------------
def V(ast, s, expected, ctx):
    got = matches(ast, s)
    if got != expected:
        raise AssertionError("VERIFY FAIL [%s]: matches(%r)=%s expected %s" % (ctx, s, got, expected))
def no_witness_bounded(lang_ast, dom_asts, lay, alphabet, maxlen, ctx):
    """Sanity check for UNSAT: no assignment of the distinct vars over `alphabet`
    with each part length in 1..maxlen makes the layout-word match lang_ast while
    satisfying the per-var domains.  Not a proof (finite), just a guard."""
    import itertools
    nv = nvars(lay)
    pool = []
    for l in range(1, maxlen+1):
        pool += ["".join(t) for t in itertools.product(alphabet, repeat=l)]
    cand = [[w for w in pool if matches(dom_asts[i], w)] for i in range(nv)]
    for combo in itertools.product(*cand):
        vals = {i: combo[i] for i in range(nv)}
        if matches(lang_ast, lhs_word(lay, vals)):
            raise AssertionError("UNSAT sanity FAIL [%s]: witness %r" % (ctx, vals))

# ===========================================================================
# FAMILIES
# ===========================================================================

# L11 -- negative-lookbehind prefix: layout in ~(Sigma* L) . C+   (SAT)
def L11():
    for ckey,(cw,cite) in list(CTX.items())[:4]:
        for rk in ["lower","digit"]:
            cre,chuman,c0,ccite = CLS[rk]
            for lay in ["xyx","xyyx"]:
                lang = nlb(word(cw), plus(cre))
                defs = ["(define-fun ctx () (RegEx String) %s)" % word(cw).smt,
                        "(define-fun lang () (RegEx String)   ;; ~(Sigma* ctx) . %s+\n  %s)" % (chuman, lang.smt)]
                asserts = ["(assert (str.in_re %s (re.+ re.allchar)))" % VAR[i] for i in range(nvars(lay))]
                asserts.append("(assert (str.in_re %s lang))" % lhs_smt(lay))
                vals = {i: c0 for i in range(nvars(lay))}
                V(lang.ast, lhs_word(lay, vals), True, "L11 %s %s %s" % (ckey,rk,lay))
                hdr = ["Neg-lookbehind prefix (generated) -- complement-concat, difficulty L2",
                       "Idiom: %s" % cite,
                       "  (?<!%s) %s+   ==   ~(Sigma* \"%s\") . %s+" % (cw, chuman, cw, chuman),
                       "Vars: %s ; layout %s" % (", ".join(VAR[i] for i in range(nvars(lay))), lay),
                       "Query: all vars in Sigma+ ; %s in ~(Sigma* \"%s\") . %s+" % (lay, cw, chuman),
                       "Status: SAT -- witness all vars=\"%s\" (split u=\"\" not ending in \"%s\", v=word in %s+)." % (c0,cw,chuman),
                       "Stresses: rcat(compl(sigma(Sigma* \"%s\")), %s+) in seq_split." % (cw,chuman),
                       "Source: mined negative-lookbehind idiom"]
                add("l11-nlb-%s-%s-%s-sat"%(ckey,rk,lay), "sat","L2","nlb",lay,defs,asserts,hdr,
                    witness="all=%s"%c0)

# L14 -- complement-concat suffix conflict on a repeated var (UNSAT, default-hard)
def L14():
    pairs = [("upper","digit"),("lower","digit"),("digit","lower"),("digit","upper")]
    for xk,rk in pairs:
        xcre,xhuman,_,_ = CLS[xk]
        rcre,rhuman,_,_ = CLS[rk]
        for ckey in ["cu","in","left"]:
            cw = CTX[ckey][0]
            for lay,m in [("xyx",2),("xyyx",2),("xyx",3)]:
                lang = nlb(word(cw), loop(rcre, m))       # ~(Sigma* cw) . R{m}
                defs = ["(define-fun ctx () (RegEx String) %s)" % word(cw).smt,
                        "(define-fun lang () (RegEx String)   ;; ~(Sigma* ctx) . %s{%d}\n  %s)" % (rhuman,m,lang.smt)]
                asserts = ["(assert (str.in_re x (re.+ %s)))" % xcre.smt]
                for i in range(1, nvars(lay)):
                    asserts.append("(assert (str.in_re %s (re.+ re.allchar)))" % VAR[i])
                asserts.append("(assert (str.in_re %s lang))" % lhs_smt(lay))
                dom = [plus(xcre).ast] + [plus(A).ast]*(nvars(lay)-1)
                no_witness_bounded(lang.ast, dom, lay, [CLS[xk][2],CLS[rk][2],"Q"], 3,
                                   "L14 %s %s %s %s m%d"%(xk,rk,ckey,lay,m))
                hdr = ["Neg-lookbehind + suffix conflict (generated) -- complement-concat, difficulty L3",
                       "Idiom: (?<!%s) ... %s{%d}$  with the leading token forced into %s." % (cw, rhuman, m, xhuman),
                       "  language = ~(Sigma* \"%s\") . %s{%d}" % (cw, rhuman, m),
                       "Vars: %s ; layout %s (ends in x)" % (", ".join(VAR[i] for i in range(nvars(lay))), lay),
                       "Query: x in %s+ , others in Sigma+ ; %s in ~(Sigma* \"%s\") . %s{%d}" % (xhuman, lay, cw, rhuman, m),
                       "Status: UNSAT -- the word ends with %s{%d} so its last char is in %s;" % (rhuman,m,rhuman),
                       "  but the layout ends in x, whose last char is in the DISJOINT class %s." % xhuman,
                       "Stresses: compl+rcat splitting then a disjoint-class refutation.",
                       "Source: mined negative-lookbehind idiom + counted suffix"]
                add("l14-conflict-%s-%s-%s-%s-m%d-unsat"%(xk,rk,ckey,lay,m), "unsat","L3","conflict",lay,defs,asserts,hdr)

# L15 -- anchored NEGATED counted membership (SAT, nseq-HARD: Failure Mode 1)
def L15():
    for ck in ["digit","lower","hex"]:
        cre,chuman,c0,ccite = CLS[ck]
        for m in [2,3,4]:
            for sep in ["-","_",":"]:
                lay = "xyx"
                Rc = cat(loop(cre,m), word(sep), loop(cre,m))
                defs = ["(define-fun cls () (RegEx String) %s)" % cre.smt,
                        "(define-fun code () (RegEx String)   ;; %s{%d} \"%s\" %s{%d}\n  %s)" % (chuman,m,sep,chuman,m,Rc.smt)]
                kmin = m
                asserts = ["(assert (str.in_re x (re.+ cls)))",
                           "(assert (>= (str.len x) %d))" % kmin]
                for i in range(1, nvars(lay)):
                    asserts.append("(assert (str.in_re %s (re.* cls)))" % VAR[i])
                asserts.append("(assert (not (str.in_re %s code)))" % lhs_smt(lay))
                vals = {i: (c0*kmin if i==0 else c0) for i in range(nvars(lay))}
                V(Rc.ast, lhs_word(lay, vals), False, "L15 %s m%d %s"%(ck,m,sep))
                diff = "L3" if m>=3 else "L2"
                sk = {'-':'dash','_':'under',':':'colon'}[sep]
                hdr = ["Negated counted membership (generated) -- neg look-around, difficulty %s" % diff,
                       "Idiom: 'is NOT exactly a %s-code %s{%d}%s%s{%d}' (negative lookaround over a" % (chuman,chuman,m,sep,chuman,m),
                       "  counted field; forces reasoning about the COMPLEMENT of a bounded loop).",
                       "Vars: %s ; layout %s" % (", ".join(VAR[i] for i in range(nvars(lay))), lay),
                       "Query: x in %s+ (|x|>=%d), y in %s* ; NOT ( %s in %s{%d}\"%s\"%s{%d} )" % (chuman,kmin,chuman,lay,chuman,m,sep,chuman,m),
                       "Status: SAT -- witness x=\"%s\", y=\"\" : all-%s word has no \"%s\", so it is" % (c0*kmin,chuman,sep),
                       "  not the separated code; the negation holds.",
                       "Stresses: complement of a bounded-loop regex -> split/DFS blow-up (nseq Failure Mode 1).",
                       "Source: %s ; counted negative look-around" % ccite]
                add("l15-negcount-%s-m%d-%s-sat"%(ck,m,sk), "sat",diff,"negcount",lay,defs,asserts,hdr,
                    witness="x=%s y="%(c0*kmin))

# L12 -- two-sided flank: ~(Sigma* L) . C+ . ~(M Sigma*)   (neg-lb + neg-la; SAT)
def L12():
    for ckey in ["cu","in"]:
        cw = CTX[ckey][0]
        for rk in ["lower","digit"]:
            cre,chuman,c0,ccite = CLS[rk]
            for mw in ["ing","ed"]:
                for lay in ["xyx","xyyx"]:
                    lang = cat(comp(cat(STAR, word(cw))), plus(cre), comp(cat(word(mw), STAR)))
                    defs = ["(define-fun lang () (RegEx String)   ;; ~(Sigma* \"%s\") . %s+ . ~(\"%s\" Sigma*)\n  %s)" % (cw,chuman,mw,lang.smt)]
                    asserts = ["(assert (str.in_re %s (re.+ re.allchar)))" % VAR[i] for i in range(nvars(lay))]
                    asserts.append("(assert (str.in_re %s lang))" % lhs_smt(lay))
                    vals = {i: c0 for i in range(nvars(lay))}
                    V(lang.ast, lhs_word(lay, vals), True, "L12 %s %s %s %s"%(ckey,rk,mw,lay))
                    hdr = ["Two-sided flank (generated) -- neg-lookbehind + neg-lookahead, difficulty L2",
                           "Idiom: (?<!%s) %s+ (?!%s)  ==  ~(Sigma* \"%s\") . %s+ . ~(\"%s\" Sigma*)" % (cw,chuman,mw,cw,chuman,mw),
                           "  (cf. corpus '(?<!...)University(?! Road)': complement on BOTH sides of a core).",
                           "Vars: %s ; layout %s" % (", ".join(VAR[i] for i in range(nvars(lay))), lay),
                           "Query: all vars in Sigma+ ; %s in ~(Sigma* \"%s\") . %s+ . ~(\"%s\" Sigma*)" % (lay,cw,chuman,mw),
                           "Status: SAT -- witness all vars=\"%s\" (u=\"\" not ending \"%s\", core in %s+, w=\"\" not starting \"%s\")." % (c0,cw,chuman,mw),
                           "Stresses: compl+rcat AND compl+lcat around a core (two-sided splitting).",
                           "Source: mined neg-lookbehind + neg-lookahead idiom"]
                    add("l12-flank-%s-%s-%s-%s-sat"%(ckey,rk,mw,lay), "sat","L2","flank",lay,defs,asserts,hdr,
                        witness="all=%s"%c0)

# L13 -- intersection of k neg-lookbehind complement-concats (SAT, default-hard gradient)
def L13():
    for ck,lay in [("lower","xyxy"),("lower","xyx"),("digit","xyxy")]:
        cre,chuman,c0,_ = CLS[ck]
        for k in [2,3,4,5]:
            Ls = ["ab","cd","ef","gh","ij"][:k]
            lang = andr(*[nlb(word(w), plus(cre)) for w in Ls])
            defs = ["(define-fun lang () (RegEx String)   ;; intersection of %d neg-lookbehinds, each . %s+\n  %s)" % (k,chuman,lang.smt)]
            asserts = ["(assert (str.in_re %s (re.+ re.allchar)))" % VAR[i] for i in range(nvars(lay))]
            asserts.append("(assert (str.in_re %s lang))" % lhs_smt(lay))
            vals = {i: c0 for i in range(nvars(lay))}
            V(lang.ast, lhs_word(lay, vals), True, "L13 %s %s k%d"%(ck,lay,k))
            diff = "L3" if k>=4 else "L2"
            hdr = ["Intersection of neg-lookbehinds (generated) -- split cross-product, difficulty %s" % diff,
                   "Idiom: %d simultaneous negative lookbehinds  AND_i (?<!%s) %s+ ." % (k, "|".join(Ls), chuman),
                   "  == intersection_i ~(Sigma* \"%s\") . %s+   (each split-set crossed with the next)." % (Ls[0],chuman),
                   "Vars: %s ; layout %s" % (", ".join(VAR[i] for i in range(nvars(lay))), lay),
                   "Query: all vars in Sigma+ ; %s in AND of %d complement-concats" % (lay,k),
                   "Status: SAT -- witness all vars=\"%s\" (u=\"\" avoids every context; core in %s+)." % (c0,chuman),
                   "Stresses: seq_split `inter` cross-product of k complement-concat split-sets (grows with k).",
                   "Source: mined multi-alternative negative-lookbehind idiom"]
            add("l13-inter-%s-%s-k%d-sat"%(ck,lay,k), "sat",diff,"inter",lay,defs,asserts,hdr,
                witness="all=%s"%c0)

# L16 -- nested neg-lookbehind (context is itself a complement-concat), SAT
def L16():
    for L,M in [("ab","cd"),("xy","zz"),("in","gg")]:
        for rk in ["lower","digit"]:
            for lay in ["xyx","xyyx"]:
                inner = nlb(word(L), word(M))                 # ~(Sigma* L) . M
                cre,chuman,c0,_ = CLS[rk]
                lang = nlb(inner, plus(cre))                  # ~(Sigma* (~(Sigma* L).M)) . C+
                defs = ["(define-fun inner () (RegEx String)  ;; ~(Sigma* \"%s\") . \"%s\"\n  %s)" % (L,M,inner.smt),
                        "(define-fun lang () (RegEx String)   ;; ~(Sigma* inner) . %s+\n  %s)" % (chuman,lang.smt)]
                asserts = ["(assert (str.in_re %s (re.+ re.allchar)))" % VAR[i] for i in range(nvars(lay))]
                asserts.append("(assert (str.in_re %s lang))" % lhs_smt(lay))
                vals = {i: c0 for i in range(nvars(lay))}
                V(lang.ast, lhs_word(lay, vals), True, "L16 %s %s %s %s"%(L,M,rk,lay))
                hdr = ["Nested neg-lookbehind (generated) -- complement inside complement, difficulty L3",
                       "Idiom: a neg-lookbehind whose forbidden context is ITSELF a neg-lookbehind pattern:",
                       "  ~(Sigma* ( ~(Sigma* \"%s\") . \"%s\" )) . %s+" % (L,M,chuman),
                       "Vars: %s ; layout %s" % (", ".join(VAR[i] for i in range(nvars(lay))), lay),
                       "Query: all vars in Sigma+ ; %s in the nested complement-concat" % lay,
                       "Status: SAT -- witness all vars=\"%s\" (u=\"\" avoids the nested context; core in %s+)." % (c0,chuman),
                       "Stresses: compl of a term containing compl+rcat (nested split expansion).",
                       "Source: mined nested-lookaround idiom (1211 corpus patterns nest a lookahead in a lookbehind)"]
                add("l16-nest-%s%s-%s-%s-sat"%(L,M,rk,lay), "sat","L3","nest",lay,defs,asserts,hdr,
                    witness="all=%s"%c0)

for T in [L11, L12, L13, L14, L15, L16]:
    T()
# ---------------------------------------------------------------------------
for f in glob.glob(os.path.join(OUT, "*.smt2")): os.remove(f)
for rec in BENCH:
    with open(os.path.join(OUT, rec["name"]+".smt2"), "w", encoding="utf-8") as fh:
        fh.write(emit(rec))
with open(os.path.join(OUT, "manifest.csv"), "w", newline="", encoding="utf-8") as fh:
    wtr = csv.writer(fh)
    wtr.writerow(["file","family","layout","nvars","difficulty","status","witness","note"])
    for r in BENCH:
        wtr.writerow([r["name"]+".smt2", r["family"], r["lay"], r["nvars"], r["diff"],
                      r["status"], r["witness"], r["note"]])
print("generated", len(BENCH), "benchmarks")
print("by status    :", dict(Counter(r["status"] for r in BENCH)))
print("by difficulty:", dict(Counter(r["diff"] for r in BENCH)))
print("by family    :", dict(Counter(r["family"] for r in BENCH)))
