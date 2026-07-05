(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- periodic, difficulty L3
;; Idiom: repetition of a fixed unit (u)+ with backreferenced fragments.
;;   unit = "ab"
;; Vars: x, y, z ; layout xyxzyz
;; Query: all vars in Sigma+ ; xyxzyz in ("ab")+
;; Status: SAT -- witness all vars = "ab" (word becomes "ab" repeated).
;; Source: periodic membership (cf. the x.y.x.y in (ab)* word-equation family)
;; ==========================================================================
(define-fun unit () (RegEx String) (str.to_re "ab"))
(declare-fun x () String)
(declare-fun y () String)
(declare-fun z () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re z (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x z y z) (re.+ unit)))
(check-sat)
