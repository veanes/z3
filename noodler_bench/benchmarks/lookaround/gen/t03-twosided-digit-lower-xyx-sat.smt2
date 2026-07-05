(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- two-sided context, difficulty L2
;; Idiom: token anchored by a start and an end class,
;;   e.g. (?<=^)[0-9] ... [a-z]$  (start [0-9], end [a-z]).
;; Vars: x, y ; layout xyx
;; Query: x in Sigma+, y in [0-9]+ ; xyx in [0-9] . Sigma* . [a-z]
;; Status: SAT -- x pinned at both ends (first in [0-9], last in [a-z]);
;;   witness x="0a", y="0".
;; Source: [0-9] x3409 / [a-z] x1818 ; two-sided look-around
;; ==========================================================================
(define-fun sc () (RegEx String) (re.range "0" "9"))
(define-fun ec () (RegEx String) (re.range "a" "z"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ (re.range "0" "9"))))
(assert (str.in_re (str.++ x y x) (re.++ sc (re.++ (re.* re.allchar) ec))))
(check-sat)
