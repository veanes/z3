(set-logic ALL)
(set-info :status unsat)
;;==========================================================================
;; Neg-lookbehind + suffix conflict (generated) -- complement-concat, difficulty L3
;; Idiom: (?<!in) ... [A-Z]{3}$  with the leading token forced into [0-9].
;;   language = ~(Sigma* "in") . [A-Z]{3}
;; Vars: x, y ; layout xyx (ends in x)
;; Query: x in [0-9]+ , others in Sigma+ ; xyx in ~(Sigma* "in") . [A-Z]{3}
;; Status: UNSAT -- the word ends with [A-Z]{3} so its last char is in [A-Z];
;;   but the layout ends in x, whose last char is in the DISJOINT class [0-9].
;; Stresses: compl+rcat splitting then a disjoint-class refutation.
;; Source: mined negative-lookbehind idiom + counted suffix
;;==========================================================================
(define-fun ctx () (RegEx String) (str.to_re "in"))
(define-fun lang () (RegEx String)   ;; ~(Sigma* ctx) . [A-Z]{3}
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "in"))) ((_ re.loop 3 3) (re.range "A" "Z"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ (re.range "0" "9"))))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) lang))
(check-sat)
