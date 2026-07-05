(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- PARITY / counting via an anchored lookahead (the length/count
;;                   difficulty axis, like L2-04), over the [^"] range.
;;
;; Source idiom (~26 occurrences in data/lookarounds.json, CSV/quote splitters):
;;     ,(?=(?:(?:[^"]*"){2})*[^"]*$)
;;   "this comma is OUTSIDE quotes" = an EVEN number of '"' follows it.
;;   Translation (the even-quote-count language, [^"] = Sigma \ {'"'}):
;;     Reven = ( [^"]* '"' [^"]* '"' )* [^"]*
;;
;; Observed (z3 4.17.0, branch c3):  default = timeout,  nseq = timeout (>300s).
;;   A HARD instance: the parity argument couples the two copies of x with a
;;   counting language, which neither configuration discharges here.  Status is
;;   established out-of-band (exhaustive check + the parity proof above).
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     y in [^"]*
;;     x . " . x . y   in   Reven
;; The two copies of x contribute 2*count_"(x) (even), the literal '"' adds 1,
;; and y (quote-free) adds 0 => the total number of '"' is ODD => the string is
;; not in Reven => UNSAT, regardless of x and y.  A genuine parity argument.
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

;; [^"] = any single char that is not '"'
(define-fun not-q () (RegEx String) (re.diff re.allchar (str.to_re "\u{22}")))

;; Reven = ( [^"]* '"' [^"]* '"' )* [^"]*   -- even number of quotes
(define-fun Reven () (RegEx String)
  (re.++
    (re.* (re.++ (re.* not-q)
          (re.++ (str.to_re "\u{22}")
          (re.++ (re.* not-q) (str.to_re "\u{22}")))))
    (re.* not-q)))

;; y has no quote
(assert (str.in_re y (re.* not-q)))
;; x . " . x . y  in Reven  -- 2*count(x) + 1 + 0 is odd => UNSAT
(assert (str.in_re (str.++ x "\u{22}" x y) Reven))

(check-sat)
