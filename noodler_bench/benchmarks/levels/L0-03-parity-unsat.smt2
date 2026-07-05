; L0-03-parity-unsat  (non-primitive parity over standard star)
; Level 0. x.a.x in (ab)*: |x.a.x|=2|x|+1 odd, (ab)* is even -> UNSAT. Split over standard star; hard for the default seq solver.
; Status unsat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): unsat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status unsat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 0) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re (str.++ x "a" x) (re.* (str.to_re "ab"))))

(check-sat)
