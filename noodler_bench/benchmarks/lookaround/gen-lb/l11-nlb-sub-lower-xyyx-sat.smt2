(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Neg-lookbehind prefix (generated) -- complement-concat, difficulty L2
;; Idiom: (?<!sub)class  -- 'class' not preceded by 'sub'
;;   (?<!sub) [a-z]+   ==   ~(Sigma* "sub") . [a-z]+
;; Vars: x, y ; layout xyyx
;; Query: all vars in Sigma+ ; xyyx in ~(Sigma* "sub") . [a-z]+
;; Status: SAT -- witness all vars="a" (split u="" not ending in "sub", v=word in [a-z]+).
;; Stresses: rcat(compl(sigma(Sigma* "sub")), [a-z]+) in seq_split.
;; Source: mined negative-lookbehind idiom
;;==========================================================================
(define-fun ctx () (RegEx String) (str.to_re "sub"))
(define-fun lang () (RegEx String)   ;; ~(Sigma* ctx) . [a-z]+
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "sub"))) (re.+ (re.range "a" "z"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y y x) lang))
(check-sat)
