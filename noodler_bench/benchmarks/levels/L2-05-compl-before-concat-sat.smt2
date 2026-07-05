; L2-05-compl-before-concat-sat  (genuine complement BEFORE a concatenation (forces split))
; Level 2. x.a.x in (~((ab)*)).c : a genuine complement is the LEFT (prefix) operand of a concat, which FORCES the split rule sigma((~R).s)=sigma(~R).s union (~R).sigma(s) -- the split boundary must cut through the De Morgan expansion. SAT (x=c -> cac; prefix 'ca' not in (ab)*).
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x='c'
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 2) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re (str.++ x "a" x) (re.++ (re.comp (re.* (str.to_re "ab"))) (str.to_re "c"))))

(check-sat)
