(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- NEGATIVE LOOKBEHIND translated to a complemented "contains"
;;                   (escape-awareness); exercises complement over ranges.
;;
;; Source idiom (~5360 lookbehind uses in data/lookarounds.json; e.g. (?<!\\)):
;;     (?<!\\);      a ';' that is NOT immediately preceded by a backslash,
;;                   i.e. an *unescaped* ';' (a real field/statement separator).
;;   User's lookbehind rule:  R(?<!L) ~= R & ~(Sigma* L).  Applied to the
;;   "no unescaped ';' anywhere" language:
;;     Forbidden = ( ';' Sigma* )                              ; ';' at the start
;;               | ( Sigma* [^\\] ';' Sigma* )                 ; ';' after a non-'\'
;;     Legal     = ~Forbidden
;;   ([^\\] and [^;\\] are genuine negated ranges over the full alphabet.)
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x in [^;\\]*                       (x has no ';' and no '\')
;;     x . ';' . y . x   in   Legal
;; The ';' inserted after the first x is preceded by the last char of x -- which
;; lies in [^;\\], hence is NOT a backslash -- (or, if x is empty, the ';' is at
;; the start).  Either way that ';' is UNESCAPED, so the string is in Forbidden
;; and NOT in Legal.  UNSAT for every x, y.
;;
;; Observed (z3 4.17.0, branch c3):  default = timeout(60s),  nseq = unsat.
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun sig-star () (RegEx String) (re.* re.allchar))            ; Sigma*
(define-fun bslash () (RegEx String) (str.to_re "\u{5c}"))           ; '\'
(define-fun semi   () (RegEx String) (str.to_re "\u{3b}"))           ; ';'
(define-fun not-bslash () (RegEx String) (re.diff re.allchar bslash)); [^\]
(define-fun not-semi-bslash () (RegEx String)                        ; [^;\]
  (re.diff re.allchar (re.union semi bslash)))

;; Forbidden = ';' Sigma*   |   Sigma* [^\] ';' Sigma*
(define-fun forbidden () (RegEx String)
  (re.union (re.++ semi sig-star)
            (re.++ sig-star (re.++ not-bslash (re.++ semi sig-star)))))
(define-fun legal () (RegEx String) (re.comp forbidden))

;; x has no ';' and no '\'
(assert (str.in_re x (re.* not-semi-bslash)))
;; x . ';' . y . x  in Legal  -- the ';' after x is unescaped => UNSAT
(assert (str.in_re (str.++ x "\u{3b}" y x) legal))

(check-sat)
