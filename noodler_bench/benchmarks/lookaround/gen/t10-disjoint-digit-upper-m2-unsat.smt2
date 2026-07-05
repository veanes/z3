(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- disjoint-range border, difficulty L2
;; Idiom: two DISJOINT character ranges concatenated ([0-9] then [A-Z]).
;; Vars: x (x2), y ; layout xyx
;; Query: x in Sigma+ ; x.y.x in [0-9]{2} . [A-Z]{2}
;; Status: UNSAT -- writing the word as x.y.x with |x|>=1 forces x's chars into
;;   BOTH ranges at once, but the ranges are disjoint.
;; Source: mined ranges (incl. astral / surrogate classes)
;; ==========================================================================
(define-fun r1 () (RegEx String) (re.range "0" "9"))
(define-fun r2 () (RegEx String) (re.range "A" "Z"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) (re.++ ((_ re.loop 2 2) r1) ((_ re.loop 2 2) r2))))
(check-sat)
