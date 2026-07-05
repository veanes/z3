(set-logic ALL)
(set-info :status sat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- BOUNDED-COUNT alternation ({3} | {6}) over a hex range;
;;                   a repeated variable coupling length to the count choice.
;;
;; Source idiom (CSS colour, ubiquitous):  #([0-9a-fA-F]{3}|[0-9a-fA-F]{6})
;;   a colour is either the short (3 hex digits) or long (6 hex digits) form.
;;   Here (lower-case hex range [0-9a-f], the genuine ECMAScript class):
;;     [0-9a-f]{3}  |  [0-9a-f]{6}                       (via re.loop + re.union)
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x in [0-9a-f]+                       (x is a non-empty hex fragment)
;;     x . y . x   in   [0-9a-f]{3} | [0-9a-f]{6}
;; The total length 2*|x| + |y| must land on exactly 3 or exactly 6, and every
;; character must be a hex digit.  SAT: e.g. x="a", y="a" -> "aaa" (short form).
;;
;; Observed (z3 4.17.0, branch c3):  default = sat,  nseq = sat  (both correct;
;;   the bounded length {3}/{6} lets nseq decide this SAT instance).
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun hexd () (RegEx String)                                   ; [0-9a-f]
  (re.union (re.range "0" "9") (re.range "a" "f")))

;; x is a non-empty run of hex digits
(assert (str.in_re x (re.+ hexd)))
;; x . y . x is a 3-digit OR 6-digit hex colour body
(assert (str.in_re (str.++ x y x)
  (re.union ((_ re.loop 3 3) hexd) ((_ re.loop 6 6) hexd))))

(check-sat)
