; L2-04-alt-even-unsat  (binary-alternating + even nonzero length (non-primitive))
; Level 2. x.a.x in (a|b)* & ~(..aa..) & ~(..bb..) with |x|=2k, k>=1: over {a,b} the term must strictly alternate; length 4k+1 forces the middle 'a' at an even index, pinning x=(ab)^k, whose second copy then starts with 'b' where an 'a' is required. UNSAT (binary alternation + length + complement, non-primitive).
; Status unsat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): unsat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status unsat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 2) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)
(declare-fun k () Int)

(assert (str.in_re (str.++ x "a" x) (re.inter (re.* (re.union (str.to_re "a") (str.to_re "b"))) (re.comp (re.++ (re.* re.allchar) (str.to_re "aa") (re.* re.allchar))) (re.comp (re.++ (re.* re.allchar) (str.to_re "bb") (re.* re.allchar))))))
(assert (= (str.len x) (* 2 k)))
(assert (>= k 1))

(check-sat)
