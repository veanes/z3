(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- parity contradiction, difficulty L3
;; Idiom: parity / counting constraint (odd number of a marker char).
;; Vars: x, y (each occurs an EVEN number of times) ; layout xyyx
;; Query: each var in [a-z]+ ; xyyx in { odd count of 'a' }
;; Status: UNSAT -- each variable occurs an even number of times, so the count of
;;   any character (incl. 'a') is even; an odd count is impossible.
;; Source: [a-z] x1818 ; parity look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "a" "z"))
(define-fun oddc () (RegEx String)   ;; odd number of 'a'
  (re.++ (re.* (re.++ (re.* (re.diff re.allchar (str.to_re "a"))) (re.++ (str.to_re "a") (re.++ (re.* (re.diff re.allchar (str.to_re "a"))) (str.to_re "a"))))) (re.++ (re.* (re.diff re.allchar (str.to_re "a"))) (re.++ (str.to_re "a") (re.* (re.diff re.allchar (str.to_re "a")))))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.+ cls)))
(assert (str.in_re (str.++ x y y x) oddc))
(check-sat)
