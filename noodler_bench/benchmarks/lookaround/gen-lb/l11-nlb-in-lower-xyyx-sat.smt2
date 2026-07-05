(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Neg-lookbehind prefix (generated) -- complement-concat, difficulty L2
;; Idiom: (?<! in ){}  -- token not preceded by 'in'
;;   (?<!in) [a-z]+   ==   ~(Sigma* "in") . [a-z]+
;; Vars: x, y ; layout xyyx
;; Query: all vars in Sigma+ ; xyyx in ~(Sigma* "in") . [a-z]+
;; Status: SAT -- witness all vars="a" (split u="" not ending in "in", v=word in [a-z]+).
;; Stresses: rcat(compl(sigma(Sigma* "in")), [a-z]+) in seq_split.
;; Source: mined negative-lookbehind idiom
;;==========================================================================
(define-fun ctx () (RegEx String) (str.to_re "in"))
(define-fun lang () (RegEx String)   ;; ~(Sigma* ctx) . [a-z]+
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "in"))) (re.+ (re.range "a" "z"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y y x) lang))
(check-sat)
