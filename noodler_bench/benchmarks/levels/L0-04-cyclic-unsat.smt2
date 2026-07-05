; L0-04-cyclic-unsat  (non-primitive over cyclic union-star)
; Level 0. x.b.x in (abc|cbab)*: cyclic derivative structure, no Boolean ops. UNSAT (verified).
; Status unsat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): unsat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status unsat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 0) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re (str.++ x "b" x) (re.* (re.union (str.to_re "abc") (str.to_re "cbab")))))

(check-sat)
