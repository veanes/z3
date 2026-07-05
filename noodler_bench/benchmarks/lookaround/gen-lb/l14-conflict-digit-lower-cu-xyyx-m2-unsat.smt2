(set-logic ALL)
(set-info :status unsat)
;;==========================================================================
;; Neg-lookbehind + suffix conflict (generated) -- complement-concat, difficulty L3
;; Idiom: (?<!cu) ... [a-z]{2}$  with the leading token forced into [0-9].
;;   language = ~(Sigma* "cu") . [a-z]{2}
;; Vars: x, y ; layout xyyx (ends in x)
;; Query: x in [0-9]+ , others in Sigma+ ; xyyx in ~(Sigma* "cu") . [a-z]{2}
;; Status: UNSAT -- the word ends with [a-z]{2} so its last char is in [a-z];
;;   but the layout ends in x, whose last char is in the DISJOINT class [0-9].
;; Stresses: compl+rcat splitting then a disjoint-class refutation.
;; Source: mined negative-lookbehind idiom + counted suffix
;;==========================================================================
(define-fun ctx () (RegEx String) (str.to_re "cu"))
(define-fun lang () (RegEx String)   ;; ~(Sigma* ctx) . [a-z]{2}
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "cu"))) ((_ re.loop 2 2) (re.range "a" "z"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ (re.range "0" "9"))))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y y x) lang))
(check-sat)
