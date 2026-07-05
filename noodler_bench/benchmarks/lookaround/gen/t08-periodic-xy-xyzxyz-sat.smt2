(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- periodic, difficulty L2
;; Idiom: repetition of a fixed unit (u)+ with backreferenced fragments.
;;   unit = "xy"
;; Vars: x, y, z ; layout xyzxyz
;; Query: all vars in Sigma+ ; xyzxyz in ("xy")+
;; Status: SAT -- witness all vars = "xy" (word becomes "xy" repeated).
;; Source: periodic membership (cf. the x.y.x.y in (ab)* word-equation family)
;; ==========================================================================
(define-fun unit () (RegEx String) (str.to_re "xy"))
(declare-fun x () String)
(declare-fun y () String)
(declare-fun z () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re z (re.+ re.allchar)))
(assert (str.in_re (str.++ x y z x y z) (re.+ unit)))
(check-sat)
