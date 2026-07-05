(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- disjoint-range border, difficulty L2
;; Idiom: two DISJOINT character ranges concatenated ([\uD800-\uDBFF] then [\uDC00-\uDFFF]).
;; Vars: x (x2), y ; layout xyx
;; Query: x in Sigma+ ; x.y.x in [\uD800-\uDBFF]{1} . [\uDC00-\uDFFF]{1}
;; Status: UNSAT -- writing the word as x.y.x with |x|>=1 forces x's chars into
;;   BOTH ranges at once, but the ranges are disjoint.
;; Source: mined ranges (incl. astral / surrogate classes)
;; ==========================================================================
(define-fun r1 () (RegEx String) (re.range "\u{d800}" "\u{dbff}"))
(define-fun r2 () (RegEx String) (re.range "\u{dc00}" "\u{dfff}"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) (re.++ ((_ re.loop 1 1) r1) ((_ re.loop 1 1) r2))))
(check-sat)
