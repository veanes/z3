(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Intersection of neg-lookbehinds (generated) -- split cross-product, difficulty L3
;; Idiom: 4 simultaneous negative lookbehinds  AND_i (?<!ab|cd|ef|gh) [0-9]+ .
;;   == intersection_i ~(Sigma* "ab") . [0-9]+   (each split-set crossed with the next).
;; Vars: x, y ; layout xyxy
;; Query: all vars in Sigma+ ; xyxy in AND of 4 complement-concats
;; Status: SAT -- witness all vars="0" (u="" avoids every context; core in [0-9]+).
;; Stresses: seq_split `inter` cross-product of k complement-concat split-sets (grows with k).
;; Source: mined multi-alternative negative-lookbehind idiom
;;==========================================================================
(define-fun lang () (RegEx String)   ;; intersection of 4 neg-lookbehinds, each . [0-9]+
  (re.inter (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "ab"))) (re.+ (re.range "0" "9"))) (re.inter (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "cd"))) (re.+ (re.range "0" "9"))) (re.inter (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "ef"))) (re.+ (re.range "0" "9"))) (re.++ (re.comp (re.++ (re.* re.allchar) (str.to_re "gh"))) (re.+ (re.range "0" "9")))))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x y) lang))
(check-sat)
