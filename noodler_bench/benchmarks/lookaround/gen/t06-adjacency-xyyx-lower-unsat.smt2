(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- forced adjacency, difficulty L3
;; Idiom: negative look-ahead (?![a-z][a-z]) 'no two adjacent [a-z] chars'.
;; Vars: x, y ; layout xyyx (the two y occurrences are ADJACENT)
;; Query: y in [a-z]+ ; xyyx in ~(Sigma* [a-z]{2} Sigma*)
;; Status: UNSAT -- the adjacent yy places two [a-z] chars side by side,
;;   forbidden by the complement, for every value of y.
;; Source: [a-z] x1818 ; negative look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "a" "z"))
(define-fun noadj () (RegEx String)  ;; no two adjacent [a-z]
  (re.comp (re.++ (re.* re.allchar) (re.++ ((_ re.loop 2 2) (re.range "a" "z")) (re.* re.allchar)))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ cls)))
(assert (str.in_re (str.++ x y y x) noadj))
(check-sat)
