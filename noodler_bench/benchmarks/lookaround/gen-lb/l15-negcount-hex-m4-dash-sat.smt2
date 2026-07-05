(set-logic ALL)
(set-info :status sat)
;;==========================================================================
;; Negated counted membership (generated) -- neg look-around, difficulty L3
;; Idiom: 'is NOT exactly a [0-9a-f]-code [0-9a-f]{4}-[0-9a-f]{4}' (negative lookaround over a
;;   counted field; forces reasoning about the COMPLEMENT of a bounded loop).
;; Vars: x, y ; layout xyx
;; Query: x in [0-9a-f]+ (|x|>=4), y in [0-9a-f]* ; NOT ( xyx in [0-9a-f]{4}"-"[0-9a-f]{4} )
;; Status: SAT -- witness x="aaaa", y="" : all-[0-9a-f] word has no "-", so it is
;;   not the separated code; the negation holds.
;; Stresses: complement of a bounded-loop regex -> split/DFS blow-up (nseq Failure Mode 1).
;; Source: [0-9a-f] hex bodies ; counted negative look-around
;;==========================================================================
(define-fun cls () (RegEx String) (re.union (re.range "0" "9") (re.range "a" "f")))
(define-fun code () (RegEx String)   ;; [0-9a-f]{4} "-" [0-9a-f]{4}
  (re.++ ((_ re.loop 4 4) (re.union (re.range "0" "9") (re.range "a" "f"))) (re.++ (str.to_re "-") ((_ re.loop 4 4) (re.union (re.range "0" "9") (re.range "a" "f"))))))
(declare-fun x () String)
(declare-fun y () String)
(assert (str.in_re x (re.+ cls)))
(assert (>= (str.len x) 4))
(assert (str.in_re y (re.* cls)))
(assert (not (str.in_re (str.++ x y x) code)))
(check-sat)
