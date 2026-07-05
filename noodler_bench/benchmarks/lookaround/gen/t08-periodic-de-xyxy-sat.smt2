(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- periodic, difficulty L2
;; Idiom: repetition of a fixed unit (u)+ with backreferenced fragments.
;;   unit = "de"
;; Vars: x, y ; layout xyxy
;; Query: all vars in Sigma+ ; xyxy in ("de")+
;; Status: SAT -- witness all vars = "de" (word becomes "de" repeated).
;; Source: periodic membership (cf. the x.y.x.y in (ab)* word-equation family)
;; ==========================================================================
(define-fun unit () (RegEx String) (str.to_re "de"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x y) (re.+ unit)))
(check-sat)
