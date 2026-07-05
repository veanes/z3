; L0-05-two-var-sat  (two-variable split over standard star)
; Level 0. x.y.x.y in (ab)*: two-variable splitting over a standard regex. SAT (x=a,y=b).
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x='', y=''
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 0) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)
(declare-fun y () String)

(assert (str.in_re (str.++ x y x y) (re.* (str.to_re "ab"))))

(check-sat)
