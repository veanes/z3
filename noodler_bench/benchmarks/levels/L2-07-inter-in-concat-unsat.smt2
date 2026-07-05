; L2-07-inter-in-concat-unsat  (primitive domain clashes with complement)
; Level 2. x in a+ (primitive) AND x.a.x in ~(Sigma* aa Sigma*): x=a^n>=1 -> x.a.x=a^(2n+1) has 'aa' -> UNSAT. Mixes L1 primitive with L2 complement-at-boundary.
; Status unsat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): unsat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status unsat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 2) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re x (re.+ (str.to_re "a"))))
(assert (str.in_re (str.++ x "a" x) (re.comp (re.++ (re.* re.allchar) (str.to_re "aa") (re.* re.allchar)))))

(check-sat)
