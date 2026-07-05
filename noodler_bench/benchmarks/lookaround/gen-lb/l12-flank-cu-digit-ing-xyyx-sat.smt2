(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Two-sided flank (generated) -- neg-lookbehind + neg-lookahead, difficulty L2
;; Idiom: (?<!cu) [0-9]+ (?!ing)  ==  ~(Sigma* "cu") . [0-9]+ . ~("ing" Sigma*)
;;   (cf. corpus '(?<!...)University(?! Road)': complement on BOTH sides of a core).
;; Vars: x, y ; layout xyyx
;; Query: all vars in Sigma+ ; xyyx in ~(Sigma* "cu") . [0-9]+ . ~("ing" Sigma*)
;; Status: SAT -- witness all vars="0" (u="" not ending "cu", core in [0-9]+, w="" not starting "ing").
;; Stresses: compl+rcat AND compl+lcat around a core (two-sided splitting).
;; Source: mined neg-lookbehind + neg-lookahead idiom
;;==========================================================================
(define-fun lang () (RegEx String)   ;; ~(Sigma* "cu") . [0-9]+ . ~("ing" Sigma*)
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "cu"))) (re.++ (re.+ (re.range "0" "9")) (re.comp (re.++ (str.to_re "ing") (re.* re.allchar))))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y y x) lang))
(check-sat)
