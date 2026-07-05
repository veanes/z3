(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- forced adjacency, difficulty L3
;; Idiom: negative look-ahead (?![\u0430-\u044F][\u0430-\u044F]) 'no two adjacent [\u0430-\u044F] chars'.
;; Vars: x, y ; layout xxyy (the two x occurrences are ADJACENT)
;; Query: x in [\u0430-\u044F]+ ; xxyy in ~(Sigma* [\u0430-\u044F]{2} Sigma*)
;; Status: UNSAT -- the adjacent xx places two [\u0430-\u044F] chars side by side,
;;   forbidden by the complement, for every value of x.
;; Source: Cyrillic runs in corpus ; negative look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "\u{430}" "\u{44f}"))
(define-fun noadj () (RegEx String)  ;; no two adjacent [\u0430-\u044F]
  (re.comp (re.++ (re.* re.allchar) (re.++ ((_ re.loop 2 2) (re.range "\u{430}" "\u{44f}")) (re.* re.allchar)))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x x y y) noadj))
(check-sat)
