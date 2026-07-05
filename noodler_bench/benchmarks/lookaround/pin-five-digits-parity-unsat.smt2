(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- BOUNDED COUNT {n} (re.loop) driving a length-parity argument;
;;                   two repeated variables (double backreference flavor).
;;
;; Source idiom: bounded quantifiers are ubiquitous in the corpus, e.g. a 5-digit
;;   code / zip / PIN  \d{5}  (also \d{4} years, [a-f0-9]{6} colors, etc.).
;;   Here the whole string must be exactly five digits:  [0-9]{5}  (via re.loop).
;;
;; Membership query (2 variables; BOTH repeated => double backreference flavor):
;;     x . x . y . y   in   [0-9]{5}
;; The length of x.x.y.y is 2*|x| + 2*|y| = 2*(|x|+|y|), which is always EVEN,
;; but [0-9]{5} forces length 5 (odd).  No x, y can satisfy this => UNSAT,
;; independent of the digit contents.  (A parity argument over a bounded count.)
;;
;; Observed (z3 4.17.0, branch c3):  default = unsat,  nseq = unsat  (both correct;
;;   the length-parity contradiction is discharged even by nseq).
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun digit () (RegEx String) (re.range "0" "9"))

;; x.x.y.y must be exactly five digits -- but its length is even => UNSAT
(assert (str.in_re (str.++ x x y y) ((_ re.loop 5 5) digit)))

(check-sat)
