(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- two-sided context, difficulty L2
;; Idiom: token anchored by a start and an end class,
;;   e.g. (?<=^)[\u00C0-\u024F] ... [0-9]$  (start [\u00C0-\u024F], end [0-9]).
;; Vars: x, y ; layout xyyx
;; Query: x in Sigma+, y in [a-z]+ ; xyyx in [\u00C0-\u024F] . Sigma* . [0-9]
;; Status: SAT -- x pinned at both ends (first in [\u00C0-\u024F], last in [0-9]);
;;   witness x="\u{c0}0", y="a".
;; Source: accented classes e.g. [a\xE1] x719 / [0-9] x3409 ; two-sided look-around
;; ==========================================================================
(define-fun sc () (RegEx String) (re.range "\u{c0}" "\u{24f}"))
(define-fun ec () (RegEx String) (re.range "0" "9"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ (re.range "a" "z"))))
(assert (str.in_re (str.++ x y y x) (re.++ sc (re.++ (re.* re.allchar) ec))))
(check-sat)
