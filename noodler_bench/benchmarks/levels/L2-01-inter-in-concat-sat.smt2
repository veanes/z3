; L2-01-inter-in-concat-sat  (intersection at a split boundary)
; Level 2. x.a.x in (contains ab)&(contains ba): sigma(R1&R2)=sigma(R1) cap sigma(R2) fires at the split boundary (cross-product). SAT (x=b -> bab).
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x='b'
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 2) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re (str.++ x "a" x) (re.inter (re.++ (re.* re.allchar) (str.to_re "ab") (re.* re.allchar)) (re.++ (re.* re.allchar) (str.to_re "ba") (re.* re.allchar)))))

(check-sat)
