; L4-01-loop-sat  (bounded repetition (re.loop) with a square)
; Level 4. x.x in (ab){1,3}: seq_split BAILS on re.loop -> counter/Parikh path. SAT (x=ab -> abab).
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x='ab'
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 4) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re (str.++ x x) (re.loop (str.to_re "ab") 1 3)))

(check-sat)
