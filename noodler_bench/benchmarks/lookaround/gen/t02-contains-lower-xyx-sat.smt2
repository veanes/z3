(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- contains-coupling, difficulty L2
;; Idiom: positive look-ahead (?=.*c) intersected with a class run (?=[a-z]+).
;; Vars: x, y ; layout xyx
;; Query: all vars in Sigma+ ; xyx in (Sigma* 'c' Sigma*) & [a-z]+
;; Status: SAT -- witness all vars = 'c' (class member containing the mark).
;; Source: [a-z] x1818 ; contains-idiom
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "a" "z"))
(define-fun lang () (RegEx String)
  (re.inter (re.++ (re.* re.allchar) (re.++ (str.to_re "c") (re.* re.allchar))) (re.+ cls)))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) lang))
(check-sat)
