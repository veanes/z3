(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- MIN-LENGTH loop {4,} over a wide Cyrillic block range, a
;;                   "contains no vowel" complement, and a repeated variable.
;;
;; Source idiom (Cyrillic consonant/vowel run matchers appear verbatim in the
;;   corpus, e.g. [\u0431\u0432\u0433...]*[\u0430\u0435\u0451...]... ; also the JS
;;   negative-lookahead "no vowel ahead" style (?![aeiou]) generalised to a block):
;;     block  = [\u0430-\u044f]                (Cyrillic small letters a..ya)
;;     vowel  = [\u0430\u0435\u0438\u043e\u0443\u044b\u044d\u044e\u044f]  (a e i o u y e yu ya)
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x           contains a Cyrillic vowel   (Sigma* vowel Sigma*)
;;     x . y . x   in block{4,}                (at least four block letters)
;;     x . y . x   in ~( Sigma* vowel Sigma* )  (contains NO vowel)
;; x is a substring of x.y.x, so a vowel in x is a vowel in x.y.x; but x.y.x is
;; required to contain no vowel.  The two constraints on the repeated variable
;; are jointly unsatisfiable => UNSAT.  Exercises the min-length loop, the wide
;; block range, and a complement together.
;;
;; Observed (z3 4.17.0, branch c3):  default = timeout (>60s),  nseq = unsat.
;;   A case where nseq WINS: it is both correct and fast, while the default seq
;;   solver does not close the min-length + complement contradiction within 60s.
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun blk () (RegEx String)                        ; [\u0430-\u044f]
  (re.range "\u{430}" "\u{44f}"))
(define-fun vowel () (RegEx String)                      ; Cyrillic vowels in the block
  (re.union (str.to_re "\u{430}")
  (re.union (str.to_re "\u{435}")
  (re.union (str.to_re "\u{438}")
  (re.union (str.to_re "\u{43e}")
  (re.union (str.to_re "\u{443}")
  (re.union (str.to_re "\u{44b}")
  (re.union (str.to_re "\u{44d}")
  (re.union (str.to_re "\u{44e}")
            (str.to_re "\u{44f}"))))))))))
(define-fun has-vowel () (RegEx String)                  ; Sigma* vowel Sigma*
  (re.++ (re.* re.allchar) (re.++ vowel (re.* re.allchar))))

;; x contains a Cyrillic vowel
(assert (str.in_re x has-vowel))
;; x . y . x is at least four block letters long ...
(assert (str.in_re (str.++ x y x) (re.++ ((_ re.loop 4 4) blk) (re.* blk))))
;; ... and contains no vowel at all
(assert (str.in_re (str.++ x y x) (re.comp has-vowel)))

(check-sat)
