(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- periodic pairs, difficulty L2
;; Idiom: stream of typed pairs ([A-Z][0-9])+ (e.g. digit-letter, hex pairs).
;; Vars: x, y ; layout xyxy
;; Query: all vars in Sigma+ ; xyxy in ([A-Z][0-9])+
;; Status: SAT -- witness all vars = "A0".
;; Source: [A-Z] x1676 / [0-9] x3409 ; periodic pairs
;; ==========================================================================
(define-fun pair () (RegEx String) (re.++ (re.range "A" "Z") (re.range "0" "9")))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x y) (re.+ pair)))
(check-sat)
