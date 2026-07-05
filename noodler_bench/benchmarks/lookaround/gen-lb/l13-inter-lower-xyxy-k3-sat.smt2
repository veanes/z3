(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Intersection of neg-lookbehinds (generated) -- split cross-product, difficulty L2
;; Idiom: 3 simultaneous negative lookbehinds  AND_i (?<!ab|cd|ef) [a-z]+ .
;;   == intersection_i ~(Sigma* "ab") . [a-z]+   (each split-set crossed with the next).
;; Vars: x, y ; layout xyxy
;; Query: all vars in Sigma+ ; xyxy in AND of 3 complement-concats
;; Status: SAT -- witness all vars="a" (u="" avoids every context; core in [a-z]+).
;; Stresses: seq_split `inter` cross-product of k complement-concat split-sets (grows with k).
;; Source: mined multi-alternative negative-lookbehind idiom
;;==========================================================================
(define-fun lang () (RegEx String)   ;; intersection of 3 neg-lookbehinds, each . [a-z]+
  (re.inter (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "ab"))) (re.+ (re.range "a" "z"))) (re.inter (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "cd"))) (re.+ (re.range "a" "z"))) (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "ef"))) (re.+ (re.range "a" "z"))))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x y) lang))
(check-sat)
