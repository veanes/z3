(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2/L3 -- NESTED COMPLEMENT inside a Kleene star (re.comp under
;;                      re.*), the construction the negative-lookahead-in-a-loop
;;                      idiom produces; plus a second, top-level complement.
;;
;; Source idiom (record / comment splitting, e.g. (?:(?!;;)[\s\S])*;; repeated,
;;   or ((?!-->).)*  bodies):  a stream of records separated by a ";;" delimiter,
;;   where each record body must NOT contain the delimiter.
;;   Translation ([^-free bodies expressed as a COMPLEMENT of a contains-language):
;;     body = ~( Sigma* ";;" Sigma* )                      (a record with no ";;")
;;     Rec  = ( body ";;" )*                               (COMPLEMENT under a *)
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x . y . x   in   Rec                     (a well-formed record stream)
;;     x . y . x   in   ~( Sigma* ";;" )        (does NOT end with the delimiter)
;;     x . y . x   in   Sigma+                  (is non-empty)
;; Every non-empty member of Rec ends with a ";;" (each block is terminated by
;; the delimiter), which directly contradicts the "does not end with ;;" clause.
;; So no x, y satisfy all three => UNSAT.  (Exercises a complement nested inside
;; a star, intersected with another complement.)
;;
;; Observed (z3 4.17.0, branch c3):  default = timeout,  nseq = timeout (>60s).
;;   A HARD instance (the nested complement under a star); status is established
;;   out-of-band (exhaustive check + the "non-empty Rec ends in ;;" proof above).
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun sig-star () (RegEx String) (re.* re.allchar))            ; Sigma*
(define-fun sig-plus () (RegEx String) (re.+ re.allchar))            ; Sigma+
(define-fun delim () (RegEx String) (str.to_re "\u{3b}\u{3b}"))      ; ";;"

;; body = ~(Sigma* ";;" Sigma*)  -- a record containing no ";;"  (COMPLEMENT)
(define-fun body () (RegEx String)
  (re.comp (re.++ sig-star (re.++ delim sig-star))))
;; Rec = ( body ";;" )*   -- the complement is NESTED inside this Kleene star
(define-fun rec () (RegEx String) (re.* (re.++ body delim)))
;; does not end with ";;"
(define-fun not-end-delim () (RegEx String) (re.comp (re.++ sig-star delim)))

;; x.y.x is a non-empty, well-formed record stream that does not end in ";;"
(assert (str.in_re (str.++ x y x) rec))
(assert (str.in_re (str.++ x y x) not-end-delim))
(assert (str.in_re (str.++ x y x) sig-plus))

(check-sat)
