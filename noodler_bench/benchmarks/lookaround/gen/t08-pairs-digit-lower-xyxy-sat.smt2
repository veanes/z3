(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- periodic pairs, difficulty L2
;; Idiom: stream of typed pairs ([0-9][a-z])+ (e.g. digit-letter, hex pairs).
;; Vars: x, y ; layout xyxy
;; Query: all vars in Sigma+ ; xyxy in ([0-9][a-z])+
;; Status: SAT -- witness all vars = "0a".
;; Source: [0-9] x3409 / [a-z] x1818 ; periodic pairs
;; ==========================================================================
(define-fun pair () (RegEx String) (re.++ (re.range "0" "9") (re.range "a" "z")))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x y) (re.+ pair)))
(check-sat)
