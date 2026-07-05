(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- bounded count {4}, difficulty L1
;; Idiom: fixed-width field [0-9]{4} (codes, ids, colour bodies).
;; Vars: x (x2), y ; layout xyx
;; Query: x in [0-9]+, y in [0-9]* ; x.y.x in [0-9]{4}
;; Status: SAT -- 2|x|+|y|=4 ; witness x="0", y="00".
;; Source: [0-9] x3409
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "0" "9"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.* cls)))
(assert (str.in_re (str.++ x y x) ((_ re.loop 4 4) cls)))
(check-sat)
