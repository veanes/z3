(set-logic ALL)
(set-info :status sat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- INTERSECTION of several unbounded "contains" languages
;;                   (the first positive-intersection instance in this set).
;;
;; Source idiom (~686 occurrences in data/lookarounds.json; "password strength"):
;;     (?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])    also (?=.*\d)(?=.*[A-Z]) etc.
;;   "the string must contain a lowercase AND an uppercase AND a digit".
;;   Translation (each positive lookahead (?=.*C) => a contains-language):
;;     (Sigma* [a-z] Sigma*) & (Sigma* [A-Z] Sigma*) & (Sigma* [0-9] Sigma*)
;;   using the genuine ECMAScript ranges [a-z], [A-Z], [0-9].
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x in [A-Za-z]*        (x holds letters only)
;;     y in [0-9]*           (y holds digits only)
;;     x . y . x   in   (Sigma*[a-z]Sigma*) & (Sigma*[A-Z]Sigma*) & (Sigma*[0-9]Sigma*)
;; The solver must ROUTE each class requirement to a variable that can supply it:
;; the lower- and upper-case letters can only come from x, the digit only from y.
;; SAT: e.g. x="aB", y="7" -> "aB7aB".  (If x were restricted to [a-z]*, the
;; uppercase requirement would be unsatisfiable -- so the routing is non-trivial.)
;;
;; Observed (z3 4.17.0, branch c3):  default = sat,  nseq = unsat (SPURIOUS: the
;;   c3 nseq spurious-unsat bug -- NO length constraint here, pure content
;;   coupling over the repeated x via the contains-intersection).
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun sig-star () (RegEx String) (re.* re.allchar))            ; Sigma*
(define-fun lower () (RegEx String) (re.range "a" "z"))
(define-fun upper () (RegEx String) (re.range "A" "Z"))
(define-fun digit () (RegEx String) (re.range "0" "9"))
(define-fun has ((c (RegEx String))) (RegEx String)                  ; Sigma* c Sigma*
  (re.++ sig-star (re.++ c sig-star)))

;; x = letters only, y = digits only
(assert (str.in_re x (re.* (re.union upper lower))))
(assert (str.in_re y (re.* digit)))
;; x . y . x contains a lowercase AND an uppercase AND a digit
(assert (str.in_re (str.++ x y x)
  (re.inter (has lower) (re.inter (has upper) (has digit)))))

(check-sat)
