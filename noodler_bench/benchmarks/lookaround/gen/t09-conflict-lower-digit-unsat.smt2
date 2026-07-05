(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- class conflict, difficulty L1
;; Idiom: a whole-token class [a-z]+ vs a fragment forced into a DISJOINT class [0-9]+.
;; Vars: x (x2), y ; layout xyx
;; Query: x in [0-9]+ ; x.y.x in [a-z]+
;; Status: UNSAT -- x's characters must be in [a-z] yet also in the disjoint
;;   class [0-9] -- impossible.
;; Source: [a-z] x1818 / [0-9] x3409
;; ==========================================================================
(define-fun whole () (RegEx String) (re.range "a" "z"))
(define-fun vc () (RegEx String) (re.range "0" "9"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ vc)))
(assert (str.in_re y (re.* re.allchar)))
(assert (str.in_re (str.++ x y x) (re.+ whole)))
(check-sat)
