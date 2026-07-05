(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- contains-coupling, difficulty L2
;; Idiom: positive look-ahead (?=.*c) intersected with a class run (?=[\u0430-\u044F]+).
;; Vars: x, y ; layout xyxy
;; Query: all vars in Sigma+ ; xyxy in (Sigma* '\u{431}' Sigma*) & [\u0430-\u044F]+
;; Status: SAT -- witness all vars = '\u{431}' (class member containing the mark).
;; Source: Cyrillic runs in corpus ; contains-idiom
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "\u{430}" "\u{44f}"))
(define-fun lang () (RegEx String)
  (re.inter (re.++ (re.* re.allchar) (re.++ (str.to_re "\u{431}") (re.* re.allchar))) (re.+ cls)))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x y) lang))
(check-sat)
