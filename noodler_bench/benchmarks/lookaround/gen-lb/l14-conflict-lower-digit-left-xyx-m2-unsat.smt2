(set-logic ALL)
(set-info :status unsat)
;;==========================================================================
;; Neg-lookbehind + suffix conflict (generated) -- complement-concat, difficulty L3
;; Idiom: (?<!left) ... [0-9]{2}$  with the leading token forced into [a-z].
;;   language = ~(Sigma* "left") . [0-9]{2}
;; Vars: x, y ; layout xyx (ends in x)
;; Query: x in [a-z]+ , others in Sigma+ ; xyx in ~(Sigma* "left") . [0-9]{2}
;; Status: UNSAT -- the word ends with [0-9]{2} so its last char is in [0-9];
;;   but the layout ends in x, whose last char is in the DISJOINT class [a-z].
;; Stresses: compl+rcat splitting then a disjoint-class refutation.
;; Source: mined negative-lookbehind idiom + counted suffix
;;==========================================================================
(define-fun ctx () (RegEx String) (str.to_re "left"))
(define-fun lang () (RegEx String)   ;; ~(Sigma* ctx) . [0-9]{2}
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "left"))) ((_ re.loop 2 2) (re.range "0" "9"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ (re.range "a" "z"))))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) lang))
(check-sat)
