(set-logic ALL)
(declare-fun v1 () String)
(declare-fun v2 () String)
(declare-fun v3 () String)
(declare-fun v4 () String)

;; R = (abc)*
(define-fun abc () (RegEx String) (str.to_re "abc"))
(define-fun R () (RegEx String) (re.* abc))

;; Constraint: v1 v2 v3 v4 "b" v1 v2 v3 v4 \in R
;; The "Cascading Contiguous Variables" test.
;; When evaluating this constraint, `v1` is the leading variable. 
;; The solver will unwind `v1`, forcing it to synthesize a stabilizer and decompose.
;; Once `v1` is subsumed/passed, `v2` becomes the NEW leading variable and identical logic must fire.
;; This cascades through v1, v2, v3, and v4 sequentially.
;; Finally, the literal "b" breaks the cycle (no word in (abc)* can start with "b" internally without 
;; consuming an "a" first in that block). But since v1..v4 is mirrored exactly on the right side,
;; resolving the parity of the prefix against the remaining suffix pushes the cycle substitutions
;; to their absolute structural limits.
(assert (str.in_re (str.++ v1 v2 v3 v4 "b" v1 v2 v3 v4) R))
(check-sat)