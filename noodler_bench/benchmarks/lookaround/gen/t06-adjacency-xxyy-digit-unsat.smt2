(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- forced adjacency, difficulty L3
;; Idiom: negative look-ahead (?![0-9][0-9]) 'no two adjacent [0-9] chars'.
;; Vars: x, y ; layout xxyy (the two x occurrences are ADJACENT)
;; Query: x in [0-9]+ ; xxyy in ~(Sigma* [0-9]{2} Sigma*)
;; Status: UNSAT -- the adjacent xx places two [0-9] chars side by side,
;;   forbidden by the complement, for every value of x.
;; Source: [0-9] x3409 ; negative look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "0" "9"))
(define-fun noadj () (RegEx String)  ;; no two adjacent [0-9]
  (re.comp (re.++ (re.* re.allchar) (re.++ ((_ re.loop 2 2) (re.range "0" "9")) (re.* re.allchar)))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x x y y) noadj))
(check-sat)
