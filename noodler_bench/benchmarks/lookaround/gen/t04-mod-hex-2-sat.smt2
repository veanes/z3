(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- modular length ([0-9a-f]{2})+, difficulty L2
;; Idiom: length-modulo look-ahead (?=([0-9a-f]{2})+) (grouping / chunking).
;; Vars: x (x2), y ; layout xyx
;; Query: x in [0-9a-f]+, y in [0-9a-f]* ; x.y.x in ([0-9a-f]{2})+
;; Status: SAT -- 2|x|+|y| = 0 mod 2 ; witness x="0", y="".
;; Source: [0-9a-f] x592 ; counting look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.union (re.range "0" "9") (re.range "a" "f")))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.* cls)))
(assert (str.in_re (str.++ x y x) (re.+ ((_ re.loop 2 2) cls))))
(check-sat)
