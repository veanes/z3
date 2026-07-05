(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Negated counted membership (generated) -- neg look-around, difficulty L3
;; Idiom: 'is NOT exactly a [a-z]-code [a-z]{4}:[a-z]{4}' (negative lookaround over a
;;   counted field; forces reasoning about the COMPLEMENT of a bounded loop).
;; Vars: x, y ; layout xyx
;; Query: x in [a-z]+ (|x|>=4), y in [a-z]* ; NOT ( xyx in [a-z]{4}":"[a-z]{4} )
;; Status: SAT -- witness x="aaaa", y="" : all-[a-z] word has no ":", so it is
;;   not the separated code; the negation holds.
;; Stresses: complement of a bounded-loop regex -> split/DFS blow-up (nseq Failure Mode 1).
;; Source: [a-z] ; counted negative look-around
;;==========================================================================
(define-fun cls () (RegEx String) (re.range "a" "z"))
(define-fun code () (RegEx String)   ;; [a-z]{4} ":" [a-z]{4}
  (re.++ ((_ re.loop 4 4) (re.range "a" "z")) (re.++ (str.to_re ":") ((_ re.loop 4 4) (re.range "a" "z")))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (>= (str.len x) 4))
(assert (str.in_re y (re.* cls)))
(assert (not (str.in_re (str.++ x y x) code)))
(check-sat)
