(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L3 -- genuine complement nested inside a Kleene star (forces the
;;                   split rule; complement is in the PREFIX/INTERIOR of a concat).
;;
;; Source idiom (delimited block, ~833 occurrences in data/lookarounds.json):
;;     %%(?:(?!%%).)*%%   ,   &quot;((?:(?!&quot;).)*)&quot;   ,   ((?!<\/).)+
;; The body ((?!D).)* matches text containing no delimiter D and (ECMAScript '.')
;; no line terminator.  With a MULTI-char delimiter (here D = "</") this is a
;; genuine ~ nested inside * that cannot be folded to a character class:
;;     ((?!</).)*   ==   DOT* & ~(Sigma* "</" Sigma*)
;; where DOT = any char except line terminators (\n \r \u2028 \u2029).
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x in /.Sigma*        (x starts with '/')
;;     x in Sigma*.<        (x ends with '<')
;;     y . x . x . y  in  Rnb
;; The x|x copy-seam forces the substring "</" (last '<' of the first x meets the
;; first '/' of the second x), which is exactly what Rnb forbids => UNSAT.
;; The repetition of x is ESSENTIAL: the forbidden substring lives on the INTERNAL
;; seam between the two copies, not inside either copy alone.
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun sig-star () (RegEx String) (re.* re.allchar))                 ; Sigma*

;; DOT = ECMAScript '.' = any single char except the 4 line terminators
(define-fun lt () (RegEx String)
  (re.union (str.to_re "\u{a}")
  (re.union (str.to_re "\u{d}")
  (re.union (str.to_re "\u{2028}") (str.to_re "\u{2029}")))))
(define-fun dot () (RegEx String) (re.diff re.allchar lt))

;; Rnb = ((?!</).)*  =  DOT* & ~(Sigma* "</" Sigma*)
(define-fun contains-close () (RegEx String)
  (re.++ sig-star (re.++ (str.to_re "</") sig-star)))
(define-fun Rnb () (RegEx String)
  (re.inter (re.* dot) (re.comp contains-close)))

;; x starts with '/' , x ends with '<'
(assert (str.in_re x (re.++ (str.to_re "/") sig-star)))
(assert (str.in_re x (re.++ sig-star (str.to_re "<"))))

;; y.x.x.y in Rnb  -- seam between the two x's spells "</" => UNSAT
(assert (str.in_re (str.++ y x x y) Rnb))

(check-sat)
