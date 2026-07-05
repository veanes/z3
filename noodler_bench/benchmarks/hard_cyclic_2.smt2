(set-logic ALL)
(declare-fun x () String)

;; R1 = (abc | cbab)*
(define-fun A () (RegEx String) (str.to_re "abc"))
(define-fun B () (RegEx String) (str.to_re "cbab"))
(define-fun R1 () (RegEx String) (re.* (re.union A B)))

;; R2 = ~(\Sigma^* "bb" \Sigma^*)
(define-fun sig-star () (RegEx String) (re.* re.allchar))
(define-fun bb () (RegEx String) (str.to_re "bb"))
(define-fun no-bb () (RegEx String) (re.comp (re.++ sig-star bb sig-star)))

;; R3 = ~(\Sigma^* "aaa" \Sigma^*)
(define-fun aaa () (RegEx String) (str.to_re "aaa"))
(define-fun no-aaa () (RegEx String) (re.comp (re.++ sig-star aaa sig-star)))

;; Intersection
(define-fun R_ext () (RegEx String) (re.inter R1 (re.inter no-bb no-aaa)))

;; Constraint: x "b" x \in R_ext
(assert (str.in_re (str.++ x "b" x) R_ext))

(check-sat)
