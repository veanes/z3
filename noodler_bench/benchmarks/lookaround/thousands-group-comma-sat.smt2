(set-logic ALL)
(set-info :status sat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- COUNTING look-ahead (length modulo 3) combined with a
;;                   no-leading-zero range constraint on a repeated variable.
;;
;; Source idiom (thousands-separator insertion, ubiquitous in number formatting;
;;   the classic look-ahead that counts remaining digits in groups of three):
;;     (?<=\d)(?=(\d{3})+(?!\d))          -- a position with a positive multiple
;;                                           of three digits to its right
;;   Applied to a whole numeric literal with no leading zero: [1-9][0-9]* whose
;;   total length is a positive multiple of 3, i.e.  [1-9][0-9]* & ([0-9]{3})+.
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x           in [1-9][0-9]*         (a number fragment, no leading zero)
;;     y           in [0-9]*
;;     x . y . x   in ([0-9]{3})+         (total length is a multiple of three)
;; The repeated x pins the first character to [1-9] and contributes 2*|x| to the
;; length, which together with |y| must be a positive multiple of 3.
;; SAT: e.g. x="1", y="0" -> "101"  (length 3).
;;
;; Observed (z3 4.17.0, branch c3):  default = sat,  nseq = UNSAT (SPURIOUS).
;;   nseq bug: the length-modulo-3 coupling on the repeated variable is decided
;;   wrongly (returns unsat on a SAT instance; witness "101").  Default correct.
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun dig () (RegEx String) (re.range "0" "9"))    ; [0-9]

;; x is a non-empty number fragment with no leading zero
(assert (str.in_re x (re.++ (re.range "1" "9") (re.* dig))))
;; y is any (possibly empty) run of digits
(assert (str.in_re y (re.* dig)))
;; x . y . x has a length that is a positive multiple of three
(assert (str.in_re (str.++ x y x) (re.+ ((_ re.loop 3 3) dig))))

(check-sat)
