(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- contains-coupling, difficulty L2
;; Idiom: positive look-ahead (?=.*c) intersected with a class run (?=[0-9a-f]+).
;; Vars: x, y ; layout xyx
;; Query: all vars in Sigma+ ; xyx in (Sigma* 'f' Sigma*) & [0-9a-f]+
;; Status: SAT -- witness all vars = 'f' (class member containing the mark).
;; Source: [0-9a-f] x592 ; contains-idiom
;; ==========================================================================
(define-fun cls () (RegEx String) (re.union (re.range "0" "9") (re.range "a" "f")))
(define-fun lang () (RegEx String)
  (re.inter (re.++ (re.* re.allchar) (re.++ (str.to_re "f") (re.* re.allchar))) (re.+ cls)))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) lang))
(check-sat)
