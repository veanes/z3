; L1-02-inter-unsat  (intersection empty)
; Level 1. x in a* & (contains b): only-a AND contains-b -> empty. UNSAT via intersection emptiness (no split).
; Status unsat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): unsat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status unsat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 1) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re x (re.inter (re.* (str.to_re "a")) (re.++ (re.* re.allchar) (str.to_re "b") (re.* re.allchar)))))

(check-sat)
