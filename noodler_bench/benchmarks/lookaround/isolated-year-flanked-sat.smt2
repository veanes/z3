(set-logic ALL)
(set-info :status sat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- COMBINED lookbehind + lookahead flanking a BOUNDED-COUNT {n}
;;                   run; class-routing across a repeated variable.
;;
;; Source idiom (isolated fixed-width number, e.g. a 4-digit year/id):
;;     (?<!\d)\d{4}(?!\d)     a run of EXACTLY four digits, not adjacent to any
;;                            other digit (a negative lookbehind AND a negative
;;                            lookahead bracketing a {4} count).
;;   Translation (contains a maximal 4-digit run; [^0-9] a genuine negated range):
;;     Isolated4 = ( Sigma* [^0-9] )?  [0-9]{4}  ( [^0-9] Sigma* )?
;;   the optional non-digit flanks realise (?<!\d) / (?!\d); the ()? realise the
;;   string-boundary alternative of each lookaround.
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x in [a-z]+                         (x is letters only -- no digits)
;;     x . y . x   in   Isolated4
;; Because x carries no digits, the four-digit run can only be supplied by y, and
;; it must stay isolated (flanked by the letters of x, or by y's own non-digits).
;; SAT: e.g. x="a", y="1234" -> "a1234a".
;;
;; Observed (z3 4.17.0, branch c3):  default = sat,  nseq = unsat (SPURIOUS: the
;;   c3 nseq spurious-unsat bug; SAT witness x="a", y="1234").
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun sig-star () (RegEx String) (re.* re.allchar))            ; Sigma*
(define-fun digit () (RegEx String) (re.range "0" "9"))
(define-fun not-digit () (RegEx String) (re.diff re.allchar digit))  ; [^0-9]

;; PRE = (start) | (... ending in a non-digit) ;  POST = (end) | (non-digit ...)
(define-fun pre  () (RegEx String) (re.opt (re.++ sig-star not-digit)))
(define-fun post () (RegEx String) (re.opt (re.++ not-digit sig-star)))
;; Isolated4 = PRE . [0-9]{4} . POST
(define-fun iso4 () (RegEx String)
  (re.++ pre (re.++ ((_ re.loop 4 4) digit) post)))

;; x is a non-empty run of lowercase letters (no digits)
(assert (str.in_re x (re.+ (re.range "a" "z"))))
;; x . y . x contains an isolated 4-digit run
(assert (str.in_re (str.++ x y x) iso4))

(check-sat)
