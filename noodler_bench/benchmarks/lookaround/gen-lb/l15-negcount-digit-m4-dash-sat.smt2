(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Negated counted membership (generated) -- neg look-around, difficulty L3
;; Idiom: 'is NOT exactly a [0-9]-code [0-9]{4}-[0-9]{4}' (negative lookaround over a
;;   counted field; forces reasoning about the COMPLEMENT of a bounded loop).
;; Vars: x, y ; layout xyx
;; Query: x in [0-9]+ (|x|>=4), y in [0-9]* ; NOT ( xyx in [0-9]{4}"-"[0-9]{4} )
;; Status: SAT -- witness x="0000", y="" : all-[0-9] word has no "-", so it is
;;   not the separated code; the negation holds.
;; Stresses: complement of a bounded-loop regex -> split/DFS blow-up (nseq Failure Mode 1).
;; Source: [0-9] (very common counted field) ; counted negative look-around
;;==========================================================================
(define-fun cls () (RegEx String) (re.range "0" "9"))
(define-fun code () (RegEx String)   ;; [0-9]{4} "-" [0-9]{4}
  (re.++ ((_ re.loop 4 4) (re.range "0" "9")) (re.++ (str.to_re "-") ((_ re.loop 4 4) (re.range "0" "9")))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (>= (str.len x) 4))
(assert (str.in_re y (re.* cls)))
(assert (not (str.in_re (str.++ x y x) code)))
(check-sat)
