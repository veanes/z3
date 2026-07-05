(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Two-sided flank (generated) -- neg-lookbehind + neg-lookahead, difficulty L2
;; Idiom: (?<!cu) [a-z]+ (?!ed)  ==  ~(Sigma* "cu") . [a-z]+ . ~("ed" Sigma*)
;;   (cf. corpus '(?<!...)University(?! Road)': complement on BOTH sides of a core).
;; Vars: x, y ; layout xyyx
;; Query: all vars in Sigma+ ; xyyx in ~(Sigma* "cu") . [a-z]+ . ~("ed" Sigma*)
;; Status: SAT -- witness all vars="a" (u="" not ending "cu", core in [a-z]+, w="" not starting "ed").
;; Stresses: compl+rcat AND compl+lcat around a core (two-sided splitting).
;; Source: mined neg-lookbehind + neg-lookahead idiom
;;==========================================================================
(define-fun lang () (RegEx String)   ;; ~(Sigma* "cu") . [a-z]+ . ~("ed" Sigma*)
  (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "cu"))) (re.++ (re.+ (re.range "a" "z")) (re.comp (re.++ (str.to_re "ed") (re.* re.allchar))))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y y x) lang))
(check-sat)
