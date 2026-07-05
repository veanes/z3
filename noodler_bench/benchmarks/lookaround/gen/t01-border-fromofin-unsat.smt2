(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- border/overlap, difficulty L2
;; Idiom: keyword alternation guarded by anchors/boundaries (very common).
;;   alternation = from | of | in
;; Vars: x (x2), y ; layout xyx = x.y.x
;; Query: x in Sigma+ ;  x.y.x in ( from | of | in )
;; Status: UNSAT -- no alternative has a non-empty border (prefix=suffix),
;;   so x.y.x with |x|>=1 cannot equal any of them.
;; Source: mined (word|word) alternations
;; ==========================================================================
(define-fun alt () (RegEx String)
  (re.union (str.to_re "from") (re.union (str.to_re "of") (str.to_re "in"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) alt))
(check-sat)
