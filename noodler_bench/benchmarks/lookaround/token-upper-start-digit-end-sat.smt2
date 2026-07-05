(set-logic ALL)
(set-info :status sat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- POSITIVE LOOKBEHIND as a suffix constraint (reverse-DFA),
;;                   combined with a prefix constraint over a repeated variable.
;;
;; Source idiom (~7955 lookbehind uses in data/lookarounds.json; e.g. (?<=\d),
;;   (?<=[A-Z]), (?<=:)).  User's rule:  R(?<=L) ~= R & (Sigma* L).
;;   Here we combine a leading-class requirement with a trailing (?<=[0-9])$:
;;     start with an uppercase letter, end on a digit --
;;     ([A-Z] Sigma*)  &  (Sigma* [0-9])
;;   using genuine ECMAScript ranges [A-Z], [0-9], [A-Za-z0-9].
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x in [A-Za-z0-9]+                                   (x is a token)
;;     x . y . x   in   ([A-Z] Sigma*) & (Sigma* [0-9])
;; Since the whole string both starts and ends with x, x itself must start with
;; an uppercase letter (forward) and end with a digit (the (?<=\d)$ lookbehind,
;; reverse-DFA).  SAT: e.g. x="A0", y="" -> "A0A0".
;;
;; Observed (z3 4.17.0, branch c3):  default = sat,  nseq = unsat (SPURIOUS: the
;;   c3 nseq spurious-unsat bug; SAT witness x="A0", y="").
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun sig-star () (RegEx String) (re.* re.allchar))            ; Sigma*
(define-fun upper () (RegEx String) (re.range "A" "Z"))
(define-fun digit () (RegEx String) (re.range "0" "9"))
(define-fun alnum () (RegEx String)                                  ; [A-Za-z0-9]
  (re.union (re.range "A" "Z") (re.union (re.range "a" "z") (re.range "0" "9"))))

;; x is a non-empty token over [A-Za-z0-9]
(assert (str.in_re x (re.+ alnum)))
;; x . y . x  starts with an uppercase letter AND ends with a digit
(assert (str.in_re (str.++ x y x)
  (re.inter (re.++ upper sig-star) (re.++ sig-star digit))))

(check-sat)
