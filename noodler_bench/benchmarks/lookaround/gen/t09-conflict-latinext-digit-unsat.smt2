(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- class conflict, difficulty L1
;; Idiom: a whole-token class [\u00C0-\u024F]+ vs a fragment forced into a DISJOINT class [0-9]+.
;; Vars: x (x2), y ; layout xyx
;; Query: x in [0-9]+ ; x.y.x in [\u00C0-\u024F]+
;; Status: UNSAT -- x's characters must be in [\u00C0-\u024F] yet also in the disjoint
;;   class [0-9] -- impossible.
;; Source: accented classes e.g. [a\xE1] x719 / [0-9] x3409
;; ==========================================================================
(define-fun whole () (RegEx String) (re.range "\u{c0}" "\u{24f}"))
(define-fun vc () (RegEx String) (re.range "0" "9"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ vc)))
(assert (str.in_re y (re.* re.allchar)))
(assert (str.in_re (str.++ x y x) (re.+ whole)))
(check-sat)
