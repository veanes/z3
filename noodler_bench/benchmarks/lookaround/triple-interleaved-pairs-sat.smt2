(set-logic ALL)
(set-info :status sat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L3 -- THREE variables, each occurring twice, INTERLEAVED so the
;;                   two occurrences of every variable sit in different periods
;;                   of the target language (genuine multi-variable interaction).
;;
;; Source idiom (repeated fixed-shape pairs -- e.g. digit/letter or type-tagged
;;   token streams (\d[a-z])+ , hex-pair encodings, coordinate lists, ...):
;;     pair = [0-9][a-z]        stream = ([0-9][a-z])+
;;
;; Membership query (3 variables x, y, z, EACH occurring twice; interleaved):
;;     x, y, z     in Sigma+
;;     x y x z y z in ([0-9][a-z])+
;; Because the whole word alternates digit,letter,digit,letter,..., each variable
;; must land on a consistent parity at BOTH of its (non-adjacent) occurrences, so
;; |x|, |y|, |z| are coupled by a length-parity condition threaded through all
;; three variables.  SAT with three DISTINCT fragments: e.g. x="1a", y="2b",
;; z="3c" -> "1a2b1a3c2b3c".
;;
;; Observed (z3 4.17.0, branch c3):  default = sat,  nseq = TIMEOUT (>60s).
;;   Default finds the interleaved three-variable solution; nseq does NOT close it
;;   within 60s (a scaling limit -- multi-variable interleaving -- not unsoundness).
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)
(declare-fun z () String)

(define-fun pair () (RegEx String)                          ; [0-9][a-z]
  (re.++ (re.range "0" "9") (re.range "a" "z")))

(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re y (re.+ re.allchar)))
(assert (str.in_re z (re.+ re.allchar)))
;; the interleaved word x y x z y z is a stream of digit-letter pairs
(assert (str.in_re (str.++ x y x z y z) (re.+ pair)))

(check-sat)
