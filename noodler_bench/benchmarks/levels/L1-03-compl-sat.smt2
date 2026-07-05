; L1-03-compl-sat  (genuine complement, d=1)
; Level 1. x in ~((ab)*): a genuine (non-char-class-eliminable) complement, depth d=1, top-level (no split). Unlike ~(a*) = .*[^a].* this cannot be rewritten to a char class. SAT (x=a, since 'a' is not of the form (ab)^n).
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x='a'
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 1) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re x (re.comp (re.* (str.to_re "ab")))))

(check-sat)
