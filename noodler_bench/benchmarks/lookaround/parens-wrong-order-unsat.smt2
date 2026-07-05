(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- BALANCED PARENTHESES (one-level Dyck) via an anchored
;;                   lookahead; ordering (open-before-close) over a repeated var.
;;
;; Source idiom (data/lookarounds.json; balanced-bracket check):
;;     (?=([^()]*\([^()]*\))*[^()]*$)
;;   "the parentheses are balanced at one nesting level" (each '(' has a later
;;   matching ')', none nested, none unmatched).  Translation (the language the
;;   lookahead pins for the whole string; [^()] is a genuine negated range):
;;     Bal1 = ( [^()]* '(' [^()]* ')' )* [^()]*
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x in [^()]*  ,  y in [^()]*
;;     x . ')' . y . '(' . x   in   Bal1
;; Since x and y contain no parentheses, the whole string has exactly one ')'
;; and one '(' and the ')' occurs BEFORE the '(' -- a close with no preceding
;; open.  Bal1 requires every ')' to follow a matching '(', so the string is not
;; balanced => UNSAT for every x, y.  (Correct order x.'('.y.')'.x would be SAT.)
;;
;; Observed (z3 4.17.0, branch c3):  default = timeout(60s),  nseq = unsat.
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun no-paren () (RegEx String)                               ; [^()]
  (re.diff re.allchar (re.union (str.to_re "(") (str.to_re ")"))))

;; Bal1 = ( [^()]* '(' [^()]* ')' )* [^()]*
(define-fun bal1 () (RegEx String)
  (re.++ (re.* (re.++ (re.* no-paren)
               (re.++ (str.to_re "(")
               (re.++ (re.* no-paren) (str.to_re ")")))))
         (re.* no-paren)))

;; x, y carry no parentheses
(assert (str.in_re x (re.* no-paren)))
(assert (str.in_re y (re.* no-paren)))
;; x . ')' . y . '(' . x : a ')' precedes the only '(' => unbalanced => UNSAT
(assert (str.in_re (str.++ x ")" y "(" x) bal1))

(check-sat)
