(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- two-sided context, difficulty L2
;; Idiom: token anchored by a start and an end class,
;;   e.g. (?<=^)[a-z] ... [0-9]$  (start [a-z], end [0-9]).
;; Vars: x, y ; layout xyx
;; Query: x in Sigma+, y in [a-z]+ ; xyx in [a-z] . Sigma* . [0-9]
;; Status: SAT -- x pinned at both ends (first in [a-z], last in [0-9]);
;;   witness x="a0", y="a".
;; Source: [a-z] x1818 / [0-9] x3409 ; two-sided look-around
;; ==========================================================================
(define-fun sc () (RegEx String) (re.range "a" "z"))
(define-fun ec () (RegEx String) (re.range "0" "9"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ (re.range "a" "z"))))
(assert (str.in_re (str.++ x y x) (re.++ sc (re.++ (re.* re.allchar) ec))))
(check-sat)
