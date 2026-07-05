(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- border/overlap, difficulty L2
;; Idiom: keyword alternation guarded by anchors/boundaries (very common).
;;   alternation = spec | test
;; Vars: x (x2), y ; layout xyx = x.y.x
;; Query: x in Sigma+ ;  x.y.x in ( spec | test )
;; Status: SAT -- 'test' has border 't' so x="t", y="es".
;; Source: mined (word|word) alternations
;; ==========================================================================
(define-fun alt () (RegEx String)
  (re.union (str.to_re "spec") (str.to_re "test")))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) alt))
(check-sat)
