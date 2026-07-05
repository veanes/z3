(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- bounded count {4}, difficulty L1
;; Idiom: fixed-width field [a-z]{4} (codes, ids, colour bodies).
;; Vars: x (x2), y ; layout xyx
;; Query: x in [a-z]+, y in [a-z]* ; x.y.x in [a-z]{4}
;; Status: SAT -- 2|x|+|y|=4 ; witness x="a", y="aa".
;; Source: [a-z] x1818
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "a" "z"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.* cls)))
(assert (str.in_re (str.++ x y x) ((_ re.loop 4 4) cls)))
(check-sat)
