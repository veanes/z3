(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- class conflict, difficulty L1
;; Idiom: a whole-token class [0-9]+ vs a fragment forced into a DISJOINT class [a-z]+.
;; Vars: x (x2), y ; layout xyx
;; Query: x in [a-z]+ ; x.y.x in [0-9]+
;; Status: UNSAT -- x's characters must be in [0-9] yet also in the disjoint
;;   class [a-z] -- impossible.
;; Source: [0-9] x3409 / [a-z] x1818
;; ==========================================================================
(define-fun whole () (RegEx String) (re.range "0" "9"))
(define-fun vc () (RegEx String) (re.range "a" "z"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ vc)))
(assert (str.in_re y (re.* re.allchar)))
(assert (str.in_re (str.++ x y x) (re.+ whole)))
(check-sat)
