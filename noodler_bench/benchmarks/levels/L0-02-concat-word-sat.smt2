; L0-02-concat-word-sat  (non-primitive over standard star)
; Level 0. x.abc.x in (abc)*: splitting fires but only over a STANDARD regex -> polynomial split-set (d=0).
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x=''
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 0) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re (str.++ x "abc" x) (re.* (str.to_re "abc"))))

(check-sat)
