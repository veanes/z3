(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- disjoint-range border, difficulty L2
;; Idiom: two DISJOINT character ranges concatenated ([\u00C0-\u024F] then [\u0430-\u044F]).
;; Vars: x (x2), y ; layout xyx
;; Query: x in Sigma+ ; x.y.x in [\u00C0-\u024F]{2} . [\u0430-\u044F]{2}
;; Status: UNSAT -- writing the word as x.y.x with |x|>=1 forces x's chars into
;;   BOTH ranges at once, but the ranges are disjoint.
;; Source: mined ranges (incl. astral / surrogate classes)
;; ==========================================================================
(define-fun r1 () (RegEx String) (re.range "\u{c0}" "\u{24f}"))
(define-fun r2 () (RegEx String) (re.range "\u{430}" "\u{44f}"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) (re.++ ((_ re.loop 2 2) r1) ((_ re.loop 2 2) r2))))
(check-sat)
