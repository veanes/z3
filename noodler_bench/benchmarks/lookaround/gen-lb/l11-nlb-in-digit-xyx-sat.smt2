(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Neg-lookbehind prefix (generated) -- complement-concat, difficulty L2
;; Idiom: (?<! in ){}  -- token not preceded by 'in'
;;   (?<!in) [0-9]+   ==   ~(Sigma* "in") . [0-9]+
;; Vars: x, y ; layout xyx
;; Query: all vars in Sigma+ ; xyx in ~(Sigma* "in") . [0-9]+
;; Status: SAT -- witness all vars="0" (split u="" not ending in "in", v=word in [0-9]+).
;; Stresses: rcat(compl(sigma(Sigma* "in")), [0-9]+) in seq_split.
;; Source: mined negative-lookbehind idiom
;;==========================================================================
(define-fun ctx () (RegEx String) (str.to_re "in"))
(define-fun lang () (RegEx String)   ;; ~(Sigma* ctx) . [0-9]+
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "in"))) (re.+ (re.range "0" "9"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) lang))
(check-sat)
