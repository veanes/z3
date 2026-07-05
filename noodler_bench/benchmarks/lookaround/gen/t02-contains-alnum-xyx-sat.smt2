(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- contains-coupling, difficulty L2
;; Idiom: positive look-ahead (?=.*c) intersected with a class run (?=[0-9A-Za-z]+).
;; Vars: x, y ; layout xyx
;; Query: all vars in Sigma+ ; xyx in (Sigma* 'a' Sigma*) & [0-9A-Za-z]+
;; Status: SAT -- witness all vars = 'a' (class member containing the mark).
;; Source: [a-zA-Z0-9] x640 ; contains-idiom
;; ==========================================================================
(define-fun cls () (RegEx String) (re.union (re.range "0" "9") (re.union (re.range "A" "Z") (re.range "a" "z"))))
(define-fun lang () (RegEx String)
  (re.inter (re.++ (re.* re.allchar) (re.++ (str.to_re "a") (re.* re.allchar))) (re.+ cls)))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) lang))
(check-sat)
