; L2-06-compl-interior-sat  (genuine complement in the INTERIOR of a concatenation)
; Level 2. x.a.x in c.(~((ab)*)).c : a genuine complement in the INTERIOR of a concatenation, flanked by literals on both sides, so the split rule is forced at both boundaries (unlike a trailing complement, which can remain a top-level membership and avoid splitting). SAT (x=c -> cac; the middle 'a' is not of the form (ab)^n).
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x='c'
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 2) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re (str.++ x "a" x) (re.++ (str.to_re "c") (re.comp (re.* (str.to_re "ab"))) (str.to_re "c"))))

(check-sat)
