(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- ALTERNATION-HEAVY literal union interacting with a repeated
;;                   variable (a "border"/overlap argument over 9 alternatives).
;;
;; Source idiom (keyword lists guarded by anchors/boundaries, extremely common;
;;   e.g. \b(GET|POST|PUT|...)\b request-method matchers):
;;     GET | POST | PUT | HEAD | DELETE | PATCH | OPTIONS | TRACE | CONNECT
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x in Sigma+                          (x is a non-empty string)
;;     x . y . x   in   (GET|POST|PUT|HEAD|DELETE|PATCH|OPTIONS|TRACE|CONNECT)
;; Writing a method w as x.y.x with |x|>=1 requires x to be a non-empty BORDER of
;; w (a prefix that is also a suffix) with 2*|x| <= |w|.  None of the nine method
;; names has such a border (they don't even start and end with the same letter),
;; so no x, y work => UNSAT.  The solver must rule this out for every alternative.
;;
;; Observed (z3 4.17.0, branch c3):  default = unsat,  nseq = unsat  (both correct).
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun methods () (RegEx String)
  (re.union (str.to_re "GET")
  (re.union (str.to_re "POST")
  (re.union (str.to_re "PUT")
  (re.union (str.to_re "HEAD")
  (re.union (str.to_re "DELETE")
  (re.union (str.to_re "PATCH")
  (re.union (str.to_re "OPTIONS")
  (re.union (str.to_re "TRACE")
            (str.to_re "CONNECT"))))))))))

;; x is non-empty
(assert (str.in_re x (re.+ re.allchar)))
;; x . y . x spells an HTTP method -> needs a non-empty border -> none exists
(assert (str.in_re (str.++ x y x) methods))

(check-sat)
