(set-logic ALL)
(set-info :status sat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- WIDE UNICODE RANGE (Latin + Latin-Extended-A) carried by a
;;                   repeated variable; identifier maximal-munch idiom.
;;
;; Source idiom (JS identifier scanners, extremely common; from the corpus, e.g.
;;   [$_A-Za-z\u00A0-\uFFFF][$\w\u00A0-\uFFFF]* with a trailing (?![$\w...]) that
;;   forbids a following identifier char -- "maximal munch"):
;;     idstart = [A-Za-z_\u00C0-\u024F]        idcont = idstart | [0-9]
;;     identifier = idstart idcont*
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x           in identifier
;;     x           starts with an upper-case Latin-1 letter [\u00C0-\u00DE]
;;     y           in idcont+                 (an identifier-continuation run)
;;     x . y . x   in identifier              (the doubled token is one identifier)
;; The interesting content -- an accented capital -- lives in the REPEATED
;; variable x, so both of its occurrences must agree on that wide-range letter.
;; SAT: e.g. x="\u00C0" (A-grave), y="a" -> "\u00C0a\u00C0".
;;
;; Observed (z3 4.17.0, branch c3):  default = sat,  nseq = sat  (both correct;
;;   the accented-capital prefix over the wide range does not trip nseq here).
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun idstart () (RegEx String)                    ; [A-Za-z_\u00C0-\u024F]
  (re.union (re.range "A" "Z")
  (re.union (re.range "a" "z")
  (re.union (str.to_re "_")
            (re.range "\u{c0}" "\u{24f}")))))
(define-fun idcont () (RegEx String)                     ; idstart | [0-9]
  (re.union idstart (re.range "0" "9")))
(define-fun ident () (RegEx String)                      ; idstart idcont*
  (re.++ idstart (re.* idcont)))

;; x is an identifier that begins with an upper-case Latin-1 accented letter
(assert (str.in_re x ident))
(assert (str.in_re x (re.++ (re.range "\u{c0}" "\u{de}") (re.* re.allchar))))
;; y is a non-empty identifier-continuation run
(assert (str.in_re y (re.+ idcont)))
;; the doubled token x . y . x is itself a single identifier
(assert (str.in_re (str.++ x y x) ident))

(check-sat)
