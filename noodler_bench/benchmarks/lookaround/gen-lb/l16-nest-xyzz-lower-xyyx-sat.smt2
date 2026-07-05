(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Nested neg-lookbehind (generated) -- complement inside complement, difficulty L3
;; Idiom: a neg-lookbehind whose forbidden context is ITSELF a neg-lookbehind pattern:
;;   ~(Sigma* ( ~(Sigma* "xy") . "zz" )) . [a-z]+
;; Vars: x, y ; layout xyyx
;; Query: all vars in Sigma+ ; xyyx in the nested complement-concat
;; Status: SAT -- witness all vars="a" (u="" avoids the nested context; core in [a-z]+).
;; Stresses: compl of a term containing compl+rcat (nested split expansion).
;; Source: mined nested-lookaround idiom (1211 corpus patterns nest a lookahead in a lookbehind)
;;==========================================================================
(define-fun inner () (RegEx String)  ;; ~(Sigma* "xy") . "zz"
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "xy"))) (str.to_re "zz")))
(define-fun lang () (RegEx String)   ;; ~(Sigma* inner) . [a-z]+
  (re.++ (re.comp (re.++ (re.* re.allchar) (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "xy"))) (str.to_re "zz")))) (re.+ (re.range "a" "z"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y y x) lang))
(check-sat)
