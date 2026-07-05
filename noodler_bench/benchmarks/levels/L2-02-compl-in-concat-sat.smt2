; L2-02-compl-in-concat-sat  (complement at a split boundary)
; Level 2. x.a.x in ~(Sigma* aa Sigma*): sigma(~R) De Morgan (2^k) at the split boundary, d=1. SAT (x=b -> bab).
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x=''
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 2) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re (str.++ x "a" x) (re.comp (re.++ (re.* re.allchar) (str.to_re "aa") (re.* re.allchar)))))

(check-sat)
