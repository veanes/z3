(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- forced adjacency, difficulty L3
;; Idiom: negative look-ahead (?![0-9a-f][0-9a-f]) 'no two adjacent [0-9a-f] chars'.
;; Vars: x, y ; layout xyyx (the two y occurrences are ADJACENT)
;; Query: y in [0-9a-f]+ ; xyyx in ~(Sigma* [0-9a-f]{2} Sigma*)
;; Status: UNSAT -- the adjacent yy places two [0-9a-f] chars side by side,
;;   forbidden by the complement, for every value of y.
;; Source: [0-9a-f] x592 ; negative look-ahead
;; ==========================================================================
(define-fun cls () (RegEx String) (re.union (re.range "0" "9") (re.range "a" "f")))
(define-fun noadj () (RegEx String)  ;; no two adjacent [0-9a-f]
  (re.comp (re.++ (re.* re.allchar) (re.++ ((_ re.loop 2 2) (re.union (re.range "0" "9") (re.range "a" "f"))) (re.* re.allchar)))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ cls)))
(assert (str.in_re (str.++ x y y x) noadj))
(check-sat)
