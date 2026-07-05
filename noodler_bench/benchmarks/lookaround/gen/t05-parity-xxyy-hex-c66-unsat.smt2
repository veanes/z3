(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- parity contradiction, difficulty L3
;; Idiom: parity / counting constraint (odd number of a marker char).
;; Vars: x, y (each occurs an EVEN number of times) ; layout xxyy
;; Query: each var in [0-9a-f]+ ; xxyy in { odd count of 'f' }
;; Status: UNSAT -- each variable occurs an even number of times, so the count of
;;   any character (incl. 'f') is even; an odd count is impossible.
;; Source: [0-9a-f] x592 ; parity look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.union (re.range "0" "9") (re.range "a" "f")))
(define-fun oddc () (RegEx String)   ;; odd number of 'f'
  (re.++ (re.* (re.++ (re.* (re.diff re.allchar (str.to_re "f"))) (re.++ (str.to_re "f") (re.++ (re.* (re.diff re.allchar (str.to_re "f"))) (str.to_re "f"))))) (re.++ (re.* (re.diff re.allchar (str.to_re "f"))) (re.++ (str.to_re "f") (re.* (re.diff re.allchar (str.to_re "f")))))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.+ cls)))
(assert (str.in_re (str.++ x x y y) oddc))
(check-sat)
