(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- modular length ([a-z]{2})+, difficulty L2
;; Idiom: length-modulo look-ahead (?=([a-z]{2})+) (grouping / chunking).
;; Vars: x (x2), y ; layout xyx
;; Query: x in [a-z]+, y in [a-z]* ; x.y.x in ([a-z]{2})+
;; Status: SAT -- 2|x|+|y| = 0 mod 2 ; witness x="a", y="".
;; Source: [a-z] x1818 ; counting look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "a" "z"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.* cls)))
(assert (str.in_re (str.++ x y x) (re.+ ((_ re.loop 2 2) cls))))
(check-sat)
