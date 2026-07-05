(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- two-sided context, difficulty L2
;; Idiom: token anchored by a start and an end class,
;;   e.g. (?<=^)[0-9a-f] ... [A-Z]$  (start [0-9a-f], end [A-Z]).
;; Vars: x, y ; layout xyx
;; Query: x in Sigma+, y in [a-z]+ ; xyx in [0-9a-f] . Sigma* . [A-Z]
;; Status: SAT -- x pinned at both ends (first in [0-9a-f], last in [A-Z]);
;;   witness x="0A", y="a".
;; Source: [0-9a-f] x592 / [A-Z] x1676 ; two-sided look-around
;; ==========================================================================
(define-fun sc () (RegEx String) (re.union (re.range "0" "9") (re.range "a" "f")))
(define-fun ec () (RegEx String) (re.range "A" "Z"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ (re.range "a" "z"))))
(assert (str.in_re (str.++ x y x) (re.++ sc (re.++ (re.* re.allchar) ec))))
(check-sat)
