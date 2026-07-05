(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L3 -- THREE variables, each occurring twice, in a MIRRORED layout,
;;                   intersected with a negative-look-ahead complement.
;;
;; Source idiom (a "no two adjacent digits" label/slug rule, expressed as an
;;   anchored negative look-ahead ^(?!.*\d\d) -- forbid two consecutive digits
;;   anywhere; combined here with three distinct character classes):
;;     forbid = ~( Sigma* [0-9]{2} Sigma* )     (no digit immediately after a digit)
;;
;; Membership query (3 variables x, y, z, EACH occurring twice; mirrored x y z z y x):
;;     x           in [A-Z]+           (an upper-case fragment)
;;     y           in [a-z]+           (a lower-case fragment)
;;     z           in [0-9]+           (a digit fragment)
;;     x y z z y x in ~( Sigma* [0-9]{2} Sigma* )
;; The mirror places the two occurrences of z ADJACENT (the central z z).  Since z
;; is a non-empty digit run, z z contains a digit immediately followed by a digit,
;; which the complement forbids -- for every choice of z.  So the Boolean
;; combination is unsatisfiable => UNSAT.
;;
;; Observed (z3 4.17.0, branch c3):  default = timeout (>60s),  nseq = unsat.
;;   A case where nseq WINS: it is correct and fast on the mirror + complement
;;   contradiction (adjacent z z forces two digits) while the default seq solver
;;   does not close it within 60s.
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)
(declare-fun z () String)

;; x, y, z drawn from three disjoint classes
(assert (str.in_re x (re.+ (re.range "A" "Z"))))
(assert (str.in_re y (re.+ (re.range "a" "z"))))
(assert (str.in_re z (re.+ (re.range "0" "9"))))
;; the mirrored word must contain NO two adjacent digits
(assert (str.in_re (str.++ x y z z y x)
  (re.comp (re.++ (re.* re.allchar)
                  (re.++ ((_ re.loop 2 2) (re.range "0" "9")) (re.* re.allchar))))))

(check-sat)
