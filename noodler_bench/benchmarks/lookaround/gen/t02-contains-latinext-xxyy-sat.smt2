(set-logic ALL)
(set-info :status sat)
;; ==========================================================================
;; Multivariable membership (generated) -- contains-coupling, difficulty L2
;; Idiom: positive look-ahead (?=.*c) intersected with a class run (?=[\u00C0-\u024F]+).
;; Vars: x, y ; layout xxyy
;; Query: all vars in Sigma+ ; xxyy in (Sigma* '\u{100}' Sigma*) & [\u00C0-\u024F]+
;; Status: SAT -- witness all vars = '\u{100}' (class member containing the mark).
;; Source: accented classes e.g. [a\xE1] x719 ; contains-idiom
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "\u{c0}" "\u{24f}"))
(define-fun lang () (RegEx String)
  (re.inter (re.++ (re.* re.allchar) (re.++ (str.to_re "\u{100}") (re.* re.allchar))) (re.+ cls)))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re (str.++ x x y y) lang))
(check-sat)
