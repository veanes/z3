(set-logic ALL)
(set-info :status sat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- TWO-SIDED context (look-behind AND look-ahead) that pins
;;                   BOTH ends of a repeated variable, one via a forward and one
;;                   via a reverse language scan.
;;
;; Source idiom (token validators that anchor a start class and an end class,
;;   e.g. "starts with a capital, ends with a digit" -- (?<=^)[A-Z].*[0-9]$ , or
;;   equivalently the two-sided ^[A-Z] ... [0-9]$ guard):
;;     starts in [A-Z]        ends in [0-9]
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x           in Sigma+               (x is a non-empty string)
;;     y           in [a-z]+                (a lower-case interior run)
;;     x . y . x   in [A-Z] . Sigma* . [0-9]   (upper-case start, digit end)
;; The FIRST occurrence of x is at the string start, so its first character must
;; be [A-Z]; the SECOND occurrence is at the string end, so its last character
;; must be [0-9].  Both ends of the repeated variable are constrained at once (a
;; forward and a reverse requirement), which forces |x| >= 2 (a single character
;; cannot be both an upper-case letter and a digit).
;; SAT: e.g. x="A1", y="a" -> "A1aA1".
;;
;; Observed (z3 4.17.0, branch c3):  default = sat,  nseq = UNSAT (SPURIOUS).
;;   nseq bug: pinning BOTH ends of the repeated variable (upper-case prefix via a
;;   forward scan, digit suffix via a reverse scan) trips it (returns unsat on a
;;   SAT instance; witness "A1aA1").  Default correct.
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

;; x non-empty, y a lower-case run
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ (re.range "a" "z"))))
;; the doubled token starts with an upper-case letter and ends with a digit
(assert (str.in_re (str.++ x y x)
  (re.++ (re.range "A" "Z") (re.++ (re.* re.allchar) (re.range "0" "9")))))

(check-sat)
