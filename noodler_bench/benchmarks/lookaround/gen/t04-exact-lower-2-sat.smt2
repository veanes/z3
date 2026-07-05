(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- bounded count {2}, difficulty L1
;; Idiom: fixed-width field [a-z]{2} (codes, ids, colour bodies).
;; Vars: x (x2), y ; layout xyx
;; Query: x in [a-z]+, y in [a-z]* ; x.y.x in [a-z]{2}
;; Status: SAT -- 2|x|+|y|=2 ; witness x="a", y="".
;; Source: [a-z] x1818
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "a" "z"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.* cls)))
(assert (str.in_re (str.++ x y x) ((_ re.loop 2 2) cls)))
(check-sat)
