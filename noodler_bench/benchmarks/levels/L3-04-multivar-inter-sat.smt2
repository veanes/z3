; L3-04-multivar-inter-sat  (multi-variable split x intersection)
; Level 3. x.y.x in (contains ab)&(contains ba): combines two-variable split branching with the intersection cross-product. SAT.
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x='', y='aba'
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 3) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)
(declare-fun y () String)

(assert (str.in_re (str.++ x y x) (re.inter (re.++ (re.* re.allchar) (str.to_re "ab") (re.* re.allchar)) (re.++ (re.* re.allchar) (str.to_re "ba") (re.* re.allchar)))))

(check-sat)
