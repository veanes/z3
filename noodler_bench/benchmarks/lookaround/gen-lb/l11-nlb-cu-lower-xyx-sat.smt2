(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Neg-lookbehind prefix (generated) -- complement-concat, difficulty L2
;; Idiom: (?<! cu)bot  -- 'bot' not preceded by 'cu'
;;   (?<!cu) [a-z]+   ==   ~(Sigma* "cu") . [a-z]+
;; Vars: x, y ; layout xyx
;; Query: all vars in Sigma+ ; xyx in ~(Sigma* "cu") . [a-z]+
;; Status: SAT -- witness all vars="a" (split u="" not ending in "cu", v=word in [a-z]+).
;; Stresses: rcat(compl(sigma(Sigma* "cu")), [a-z]+) in seq_split.
;; Source: mined negative-lookbehind idiom
;;==========================================================================
(define-fun ctx () (RegEx String) (str.to_re "cu"))
(define-fun lang () (RegEx String)   ;; ~(Sigma* ctx) . [a-z]+
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "cu"))) (re.+ (re.range "a" "z"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) lang))
(check-sat)
