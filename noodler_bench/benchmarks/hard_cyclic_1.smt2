(set-logic ALL)
(declare-fun x () String)

;; R = (abc | cbab)*
(define-fun A () (RegEx String) (str.to_re "abc"))
(define-fun B () (RegEx String) (str.to_re "cbab"))
(define-fun R () (RegEx String) (re.* (re.union A B)))

;; Constraint: x "b" x \in R
(assert (str.in_re (str.++ x "b" x) R))

(check-sat)
