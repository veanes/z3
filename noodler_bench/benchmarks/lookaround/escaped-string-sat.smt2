(set-logic ALL)
(set-info :status sat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- Kleene star over a union that includes an escape group;
;;                   motivated by the unescaped-delimiter lookbehind (?<!\\)".
;;
;; Source idiom (escaped double-quoted string, ~619 unescaped-delimiter
;; occurrences in data/lookarounds.json):
;;     "(?:[^"\\]|\\.)*"        closing " is the first one not preceded by '\'
;; The lookbehind (?<!\\)" is a suffix/reverse constraint ~(Sigma* '\')."; here
;; it is captured structurally by the grammar (a body char is either a NON
;; quote/backslash [^"\\], or a backslash followed by any char \\.):
;;     Rstr = " ( [^"\\] | \\ . )* "
;; using real ECMAScript ranges: [^"\\] = Sigma \ {", \}, and \\. = '\' then any.
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     " . x . " . x . y . "   in  Rstr ,   |x|>0 , |y|>0
;; The literal middle '"' is inside the quoted body, so it must be ESCAPED: the
;; solver must give x a suffix that is an ODD run of '\' (so "."x."." = ...\" is
;; an escaped quote), while the second copy of x followed by y must still leave
;; the final '"' unescaped.  SAT witness e.g. x="\", y="b"  ->  "\"\b".
;; (x="" or x ending in an EVEN run of '\' is UNSAT: the middle quote closes the
;; string early or the final quote gets escaped.)
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

;; [^"\\] = any single char that is not '"' (\u22) and not '\' (\u5c)
(define-fun normal () (RegEx String)
  (re.diff re.allchar (re.union (str.to_re "\u{22}") (str.to_re "\u{5c}"))))
;; \\.  = backslash followed by any single char (robust \\[\s\S] form)
(define-fun esc () (RegEx String)
  (re.++ (str.to_re "\u{5c}") re.allchar))
;; Rstr = " ( [^"\\] | \\. )* "
(define-fun Rstr () (RegEx String)
  (re.++ (str.to_re "\u{22}")
  (re.++ (re.* (re.union normal esc)) (str.to_re "\u{22}"))))

;; " . x . " . x . y . "  in  Rstr, with both variables non-empty
(assert (str.in_re
  (str.++ "\u{22}" x "\u{22}" x y "\u{22}")
  Rstr))
(assert (> (str.len x) 0))
(assert (> (str.len y) 0))

(check-sat)
