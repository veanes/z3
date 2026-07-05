(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- ASTRAL (beyond-BMP) code-point ranges; a border / overlap
;;                   argument over two DISJOINT emoji ranges and a repeated var.
;;
;; Source idiom (emoji matchers over astral ranges appear throughout the corpus,
;;   e.g. character classes spanning surrogate pairs / [\u{1F600}-...]).  Here two
;;   disjoint emoticon sub-blocks:
;;     happy = [\u{1F600}-\u{1F60F}]        (grinning ... upside-down faces)
;;     angry = [\u{1F620}-\u{1F62F}]        (angry ... sleepy faces)
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x           in Sigma+               (x is a non-empty string)
;;     x . y . x   in happy . angry        (exactly one happy then one angry face)
;; happy.angry has length two with the two positions drawn from DISJOINT ranges.
;; Writing it as x.y.x with |x|>=1 forces |x|=1 and y="" (2*|x| <= 2), so the
;; single character x would have to lie in happy AND in angry at once -- but the
;; astral ranges do not overlap => UNSAT.  Exercises range reasoning on code
;; points above U+FFFF.
;;
;; Observed (z3 4.17.0, branch c3):  default = unsat,  nseq = unsat  (both correct;
;;   the border argument over astral (beyond-BMP) ranges is decided by both).
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun happy () (RegEx String) (re.range "\u{1f600}" "\u{1f60f}"))
(define-fun angry () (RegEx String) (re.range "\u{1f620}" "\u{1f62f}"))

;; x is non-empty; x . y . x is one happy face followed by one angry face
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) (re.++ happy angry)))

(check-sat)
