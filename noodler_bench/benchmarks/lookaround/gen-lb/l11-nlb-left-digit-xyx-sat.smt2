(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Neg-lookbehind prefix (generated) -- complement-concat, difficulty L2
;; Idiom: (?<! left) join  -- SQL join not preceded by 'left'
;;   (?<!left) [0-9]+   ==   ~(Sigma* "left") . [0-9]+
;; Vars: x, y ; layout xyx
;; Query: all vars in Sigma+ ; xyx in ~(Sigma* "left") . [0-9]+
;; Status: SAT -- witness all vars="0" (split u="" not ending in "left", v=word in [0-9]+).
;; Stresses: rcat(compl(sigma(Sigma* "left")), [0-9]+) in seq_split.
;; Source: mined negative-lookbehind idiom
;;==========================================================================
(define-fun ctx () (RegEx String) (str.to_re "left"))
(define-fun lang () (RegEx String)   ;; ~(Sigma* ctx) . [0-9]+
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "left"))) (re.+ (re.range "0" "9"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) lang))
(check-sat)
