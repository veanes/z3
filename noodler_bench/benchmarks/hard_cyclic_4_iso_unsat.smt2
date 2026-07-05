(set-logic ALL)
(declare-fun x () String)

;; R1 = ~(\Sigma^* "ab" \Sigma^*)
;; Semantic meaning: The set of all strings that do NOT contain the subword "ab"
(define-fun sig-star () (RegEx String) (re.* re.allchar))
(define-fun ab () (RegEx String) (str.to_re "ab"))
(define-fun r1 () (RegEx String) (re.comp (re.++ sig-star (re.++ ab sig-star))))

;; R2 = b^* a^*  
;; Semantic meaning: Structurally different, but mathematically identical to R1 (no "ab" can appear).
(define-fun b-star () (RegEx String) (re.* (str.to_re "b")))
(define-fun a-star () (RegEx String) (re.* (str.to_re "a")))
(define-fun r2 () (RegEx String) (re.++ b-star a-star))

;; The intersection of R1 and R2 should mathematically just be identical to R1 (or R2).
;; But structurally, an unwinder faces a massive task validating parallel paths across complement blocks.
(define-fun iso-intersect () (RegEx String) (re.inter r1 r2))

;; We constrain the length to be at least 4 characters to avoid trivial \epsilon base cases
(define-fun len4 () (RegEx String) 
  (re.++ re.allchar (re.++ re.allchar (re.++ re.allchar (re.++ re.allchar sig-star)))))

(define-fun R () (RegEx String) (re.inter iso-intersect len4))

;; Constraint: x "ba" x \in R
;; Explicitly matching the paper's equivalence section: u = xbax yields UNSAT.
;; Tricky because:
;; If x = \epsilon, "ba" has length 2 (fails len4 constraint).
;; If x has length > 0, to avoid "ab", x can only be "b...a" or similar. But placing it in `x "ba" x` inevitably creates an "ab" sequence, guaranteeing UNSAT. 
;; Tests whether the SCC graph isomorphism successfully stabilizes across complements and intersections.
(assert (str.in_re (str.++ x "ba" x) R))

(check-sat)