(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- bounded count {6}, difficulty L1
;; Idiom: fixed-width field [a-z]{6} (codes, ids, colour bodies).
;; Vars: x (x2), y ; layout xyx
;; Query: x in [a-z]+, y in [a-z]* ; x.y.x in [a-z]{6}
;; Status: SAT -- 2|x|+|y|=6 ; witness x="a", y="aaaa".
;; Source: [a-z] x1818
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "a" "z"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.* cls)))
(assert (str.in_re (str.++ x y x) ((_ re.loop 6 6) cls)))
(check-sat)
