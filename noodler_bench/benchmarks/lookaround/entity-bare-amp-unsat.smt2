(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- complement of an UNBOUNDED language ([^&]* is unbounded);
;;                   the "no-Y-before-X" negative-lookahead idiom, over a range.
;;
;; Source idiom (~517 occurrences in data/lookarounds.json):
;;     &(?![^&]*;)     an '&' that does NOT begin an HTML entity
;;                     (no ';' occurs before the next '&' or end-of-string)
;;   also: ,(?![^<]*>) (comma outside a tag),  (?![^[]*]) (outside brackets).
;;   Translation:   (?![^&]*;)  ~=  ~([^&]* ';' Sigma*)
;;   so a "bare ampersand" language is:   '&' . ~([^&]* ';' Sigma*)
;;   where [^&] = Sigma \ {'&'} is a genuine (large) negated range.
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x in [^&]*
;;     & . x . ; . y . x   in   Rbare
;; Since x contains no '&', the fragment "x;" right after the leading '&' matches
;; [^&]* ';' -- i.e. it looks exactly like the beginning of an entity -- so the
;; string is NOT bare and the membership is UNSAT, for every x, y.
;;
;; Observed (z3 4.17.0, branch c3):  default = timeout(60s),  nseq = unsat.
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun sig-star () (RegEx String) (re.* re.allchar))              ; Sigma*
;; [^&] = any single char that is not '&'
(define-fun not-amp () (RegEx String) (re.diff re.allchar (str.to_re "&")))

;; "looks like an entity" = [^&]* ';' Sigma*     (a ';' reachable before the next '&')
(define-fun looks-entity () (RegEx String)
  (re.++ (re.* not-amp) (re.++ (str.to_re ";") sig-star)))
;; Rbare = '&' . ~(looks-entity)
(define-fun Rbare () (RegEx String)
  (re.++ (str.to_re "&") (re.comp looks-entity)))

;; x has no '&'
(assert (str.in_re x (re.* not-amp)))
;; & . x . ; . y . x  in Rbare  -- "x;" after '&' matches [^&]*';' => UNSAT
(assert (str.in_re (str.++ "&" x ";" y x) Rbare))

(check-sat)
