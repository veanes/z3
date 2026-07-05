(set-logic ALL)
(set-info :status sat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L3 -- THREE variables, each occurring TWICE (adjacent doubling);
;;                   a bounded length that couples all three at once.
;;
;; Source idiom (CSS hex-colour shorthand expansion, ubiquitous: #abc -> #aabbcc,
;;   where each of the three shorthand digits is DOUBLED; the doubled-digit form
;;   is exactly the backreference ([0-9a-f])\1 repeated three times):
;;     hexd = [0-9a-f]           colour body = hexd{6}
;;
;; Membership query (3 variables x, y, z, EACH occurring twice):
;;     x, y, z     in [0-9a-f]+            (three non-empty hex fragments)
;;     x x y y z z in [0-9a-f]{6}          (a full 6-digit colour body)
;; The exact length 6 with three doubled fragments forces |x|=|y|=|z|=1, i.e. the
;; three shorthand digits.  SAT: e.g. x="a", y="b", z="c" -> "aabbcc".
;;
;; Observed (z3 4.17.0, branch c3):  default = sat,  nseq = sat  (both correct;
;;   the bounded length {6} lets both decide this three-variable instance).
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)
(declare-fun z () String)

(define-fun hexd () (RegEx String)                                  ; [0-9a-f]
  (re.union (re.range "0" "9") (re.range "a" "f")))

(assert (str.in_re x (re.+ hexd)))
(assert (str.in_re y (re.+ hexd)))
(assert (str.in_re z (re.+ hexd)))
;; the doubled shorthand x x y y z z is a full six-digit colour body
(assert (str.in_re (str.++ x x y y z z) ((_ re.loop 6 6) hexd)))

(check-sat)
