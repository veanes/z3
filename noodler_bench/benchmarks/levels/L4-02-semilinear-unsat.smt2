; L4-02-semilinear-unsat  (semilinear length gap (CEGAR))
; Level 4. x in (aa)* | (aaa)* AND |x|=17: 17 is neither 2k nor 3k -> UNSAT. Semilinear/CEGAR length reasoning (Parikh path).
; Status unsat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): unsat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status unsat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 4) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)
(declare-fun k () Int)

(assert (str.in_re x (re.union (re.* (str.to_re "aa")) (re.* (str.to_re "aaa")))))
(assert (= (str.len x) 17))

(check-sat)
