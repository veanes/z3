(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- parity contradiction, difficulty L3
;; Idiom: parity / counting constraint (odd number of a marker char).
;; Vars: x, y (each occurs an EVEN number of times) ; layout xyyx
;; Query: each var in [0-9]+ ; xyyx in { odd count of '0' }
;; Status: UNSAT -- each variable occurs an even number of times, so the count of
;;   any character (incl. '0') is even; an odd count is impossible.
;; Source: [0-9] x3409 ; parity look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "0" "9"))
(define-fun oddc () (RegEx String)   ;; odd number of '0'
  (re.++ (re.* (re.++ (re.* (re.diff re.allchar (str.to_re "0"))) (re.++ (str.to_re "0") (re.++ (re.* (re.diff re.allchar (str.to_re "0"))) (str.to_re "0"))))) (re.++ (re.* (re.diff re.allchar (str.to_re "0"))) (re.++ (str.to_re "0") (re.* (re.diff re.allchar (str.to_re "0")))))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.+ cls)))
(assert (str.in_re (str.++ x y y x) oddc))
(check-sat)
