(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- parity contradiction, difficulty L3
;; Idiom: parity / counting constraint (odd number of a marker char).
;; Vars: x, y (each occurs an EVEN number of times) ; layout xyyx
;; Query: each var in [\u0430-\u044F]+ ; xyyx in { odd count of '\u{430}' }
;; Status: UNSAT -- each variable occurs an even number of times, so the count of
;;   any character (incl. '\u{430}') is even; an odd count is impossible.
;; Source: Cyrillic runs in corpus ; parity look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "\u{430}" "\u{44f}"))
(define-fun oddc () (RegEx String)   ;; odd number of '\u{430}'
  (re.++ (re.* (re.++ (re.* (re.diff re.allchar (str.to_re "\u{430}"))) (re.++ (str.to_re "\u{430}") (re.++ (re.* (re.diff re.allchar (str.to_re "\u{430}"))) (str.to_re "\u{430}"))))) (re.++ (re.* (re.diff re.allchar (str.to_re "\u{430}"))) (re.++ (str.to_re "\u{430}") (re.* (re.diff re.allchar (str.to_re "\u{430}")))))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (str.in_re y (re.+ cls)))
(assert (str.in_re (str.++ x y y x) oddc))
(check-sat)
