(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Neg-lookbehind prefix (generated) -- complement-concat, difficulty L2
;; Idiom: (?<! left) join  -- SQL join not preceded by 'left'
;;   (?<!left) [a-z]+   ==   ~(Sigma* "left") . [a-z]+
;; Vars: x, y ; layout xyx
;; Query: all vars in Sigma+ ; xyx in ~(Sigma* "left") . [a-z]+
;; Status: SAT -- witness all vars="a" (split u="" not ending in "left", v=word in [a-z]+).
;; Stresses: rcat(compl(sigma(Sigma* "left")), [a-z]+) in seq_split.
;; Source: mined negative-lookbehind idiom
;;==========================================================================
(define-fun ctx () (RegEx String) (str.to_re "left"))
(define-fun lang () (RegEx String)   ;; ~(Sigma* ctx) . [a-z]+
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "left"))) (re.+ (re.range "a" "z"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) lang))
(check-sat)
