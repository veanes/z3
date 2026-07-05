(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- modular length ([0-9]{5})+, difficulty L2
;; Idiom: length-modulo look-ahead (?=([0-9]{5})+) (grouping / chunking).
;; Vars: x (x2), y ; layout xyx
;; Query: x in [0-9]+, y in [0-9]* ; x.y.x in ([0-9]{5})+
;; Status: SAT -- 2|x|+|y| = 0 mod 5 ; witness x="0", y="000".
;; Source: [0-9] x3409 ; counting look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "0" "9"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.* cls)))
(assert (str.in_re (str.++ x y x) (re.+ ((_ re.loop 5 5) cls))))
(check-sat)
