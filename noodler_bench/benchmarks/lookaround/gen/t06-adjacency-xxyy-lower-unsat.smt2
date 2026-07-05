(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- forced adjacency, difficulty L3
;; Idiom: negative look-ahead (?![a-z][a-z]) 'no two adjacent [a-z] chars'.
;; Vars: x, y ; layout xxyy (the two x occurrences are ADJACENT)
;; Query: x in [a-z]+ ; xxyy in ~(Sigma* [a-z]{2} Sigma*)
;; Status: UNSAT -- the adjacent xx places two [a-z] chars side by side,
;;   forbidden by the complement, for every value of x.
;; Source: [a-z] x1818 ; negative look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "a" "z"))
(define-fun noadj () (RegEx String)  ;; no two adjacent [a-z]
  (re.comp (re.++ (re.* re.allchar) (re.++ ((_ re.loop 2 2) (re.range "a" "z")) (re.* re.allchar)))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x x y y) noadj))
(check-sat)
