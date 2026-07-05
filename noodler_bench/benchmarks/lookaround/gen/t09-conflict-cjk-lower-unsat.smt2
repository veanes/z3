(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- class conflict, difficulty L1
;; Idiom: a whole-token class [\u4E00-\u9FFF]+ vs a fragment forced into a DISJOINT class [a-z]+.
;; Vars: x (x2), y ; layout xyx
;; Query: x in [a-z]+ ; x.y.x in [\u4E00-\u9FFF]+
;; Status: UNSAT -- x's characters must be in [\u4E00-\u9FFF] yet also in the disjoint
;;   class [a-z] -- impossible.
;; Source: CJK ranges / [a-z] x1818
;; ==========================================================================
(define-fun whole () (RegEx String) (re.range "\u{4e00}" "\u{9fff}"))
(define-fun vc () (RegEx String) (re.range "a" "z"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ vc)))
(assert (str.in_re y (re.* re.allchar)))
(assert (str.in_re (str.++ x y x) (re.+ whole)))
(check-sat)
