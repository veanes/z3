; L1-06-multi-compl-unsat  (5-way intersection with complements)
; Level 1. x over {a,b}, contains a, contains b, but no 'ab' and no 'ba': over {a,b} any string with both letters has an ab or ba adjacency -> empty. UNSAT (d=1, 5-way intersection).
; Status unsat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): unsat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status unsat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 1) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re x (re.inter (re.* (re.union (str.to_re "a") (str.to_re "b"))) (re.++ (re.* re.allchar) (str.to_re "a") (re.* re.allchar)) (re.++ (re.* re.allchar) (str.to_re "b") (re.* re.allchar)) (re.comp (re.++ (re.* re.allchar) (str.to_re "ab") (re.* re.allchar))) (re.comp (re.++ (re.* re.allchar) (str.to_re "ba") (re.* re.allchar))))))

(check-sat)
