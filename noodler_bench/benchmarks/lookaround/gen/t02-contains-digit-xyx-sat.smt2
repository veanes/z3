(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- contains-coupling, difficulty L2
;; Idiom: positive look-ahead (?=.*c) intersected with a class run (?=[0-9]+).
;; Vars: x, y ; layout xyx
;; Query: all vars in Sigma+ ; xyx in (Sigma* '2' Sigma*) & [0-9]+
;; Status: SAT -- witness all vars = '2' (class member containing the mark).
;; Source: [0-9] x3409 ; contains-idiom
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "0" "9"))
(define-fun lang () (RegEx String)
  (re.inter (re.++ (re.* re.allchar) (re.++ (str.to_re "2") (re.* re.allchar))) (re.+ cls)))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) lang))
(check-sat)
