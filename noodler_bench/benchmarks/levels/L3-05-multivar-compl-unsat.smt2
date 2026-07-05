; L3-05-multivar-compl-unsat  (multi-variable complement clash inside concat)
; Level 3. x.y.x in ~(contains a) & (contains b), with y in a+ (primitive): y contributes at least one 'a', so the term x.y.x always contains 'a' and cannot lie in ~(contains a). UNSAT. Multi-variable split with complement+intersection inside the concatenation.
; Status unsat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): unsat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status unsat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 3) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)
(declare-fun y () String)

(assert (str.in_re (str.++ x y x) (re.inter (re.comp (re.++ (re.* re.allchar) (str.to_re "a") (re.* re.allchar))) (re.++ (re.* re.allchar) (str.to_re "b") (re.* re.allchar)))))
(assert (str.in_re y (re.+ (str.to_re "a"))))

(check-sat)
