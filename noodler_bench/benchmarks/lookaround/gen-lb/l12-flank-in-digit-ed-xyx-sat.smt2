(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Two-sided flank (generated) -- neg-lookbehind + neg-lookahead, difficulty L2
;; Idiom: (?<!in) [0-9]+ (?!ed)  ==  ~(Sigma* "in") . [0-9]+ . ~("ed" Sigma*)
;;   (cf. corpus '(?<!...)University(?! Road)': complement on BOTH sides of a core).
;; Vars: x, y ; layout xyx
;; Query: all vars in Sigma+ ; xyx in ~(Sigma* "in") . [0-9]+ . ~("ed" Sigma*)
;; Status: SAT -- witness all vars="0" (u="" not ending "in", core in [0-9]+, w="" not starting "ed").
;; Stresses: compl+rcat AND compl+lcat around a core (two-sided splitting).
;; Source: mined neg-lookbehind + neg-lookahead idiom
;;==========================================================================
(define-fun lang () (RegEx String)   ;; ~(Sigma* "in") . [0-9]+ . ~("ed" Sigma*)
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "in"))) (re.++ (re.+ (re.range "0" "9")) (re.comp (re.++ (str.to_re "ed") (re.* re.allchar))))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) lang))
(check-sat)
