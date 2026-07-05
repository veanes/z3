(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- two-sided context, difficulty L2
;; Idiom: token anchored by a start and an end class,
;;   e.g. (?<=^)[A-Z] ... [\u0430-\u044F]$  (start [A-Z], end [\u0430-\u044F]).
;; Vars: x, y ; layout xyyx
;; Query: x in Sigma+, y in [a-z]+ ; xyyx in [A-Z] . Sigma* . [\u0430-\u044F]
;; Status: SAT -- x pinned at both ends (first in [A-Z], last in [\u0430-\u044F]);
;;   witness x="A\u{430}", y="a".
;; Source: [A-Z] x1676 / Cyrillic runs in corpus ; two-sided look-around
;; ==========================================================================
(define-fun sc () (RegEx String) (re.range "A" "Z"))
(define-fun ec () (RegEx String) (re.range "\u{430}" "\u{44f}"))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ (re.range "a" "z"))))
(assert (str.in_re (str.++ x y y x) (re.++ sc (re.++ (re.* re.allchar) ec))))
(check-sat)
