; L0-01-prim-star-sat  (primitive membership, standard star)
; Level 0. Primitive x in (ab)*: single variable, NO split (Lemma 1 emptiness). Baseline.
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x=''
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 0) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re x (re.* (str.to_re "ab"))))

(check-sat)
