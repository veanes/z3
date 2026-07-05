(set-logic ALL)
(set-info :status unsat)
;; ==========================================================================
;; Multivariable membership (generated) -- nested complement in a star, difficulty L3
;; Idiom: record stream ( (?:(?!D)[..])* D )* with a global (?!.*D) 'no delimiter'.
;;   delimiter D = '/'
;; Vars: x (x2), y ; layout xyx
;; Query: x in Sigma+ ; x.y.x in ( body '/' )* & ~(Sigma* '/' Sigma*) & Sigma+
;; Status: UNSAT -- every non-empty member of ( body D )* ends with D, but the
;;   'no delimiter' complement forbids D; a non-empty word cannot satisfy both.
;; Source: [a-z] x1818 ; nested negative look-ahead (HARD for the solver)
;; ==========================================================================
(define-fun cls () (RegEx String) (re.range "a" "z"))
(define-fun body () (RegEx String)  ;; [a-z] chars, no delimiter
  (re.inter (re.* cls) (re.comp (re.++ (re.* re.allchar) (re.++ (str.to_re "/") (re.* re.allchar))))))
(define-fun rec () (RegEx String)   ;; ( body '/' )*
  (re.* (re.++ body (str.to_re "/"))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) rec))
(assert (str.in_re (str.++ x y x) (re.comp (re.++ (re.* re.allchar) (re.++ (str.to_re "/") (re.* re.allchar))))))
(assert (str.in_re (str.++ x y x) (re.+ re.allchar)))
(check-sat)
