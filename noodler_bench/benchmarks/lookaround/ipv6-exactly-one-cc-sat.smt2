(set-logic ALL)
(set-info :status sat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- intersection of a positive "contains" and a genuine
;;                   complement, plus a character-RANGE restriction.
;;
;; Source idiom (IPv6 abbreviation rule, from an IPv6 matcher in
;; data/lookarounds.json):        (?=.*::)(?!.*::.+::)
;;   (?=.*::)     "contains ::"                      ~=  (Sigma* :: Sigma*)
;;   (?!.*::.+::) "no two ::-groups"                 ~=  ~(Sigma* :: Sigma+ :: Sigma*)
;; and IPv6 text is restricted to the hex+colon RANGE [0-9A-Fa-f:].  So:
;;   R = (Sigma* :: Sigma*)  &  ~(Sigma* :: Sigma+ :: Sigma*)  &  [0-9A-Fa-f:]*
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x . y . x  in  R ,   |x|>0 , |y|>0
;; SAT: the solver must place exactly one "::" while respecting that the repeated
;; x cannot itself introduce a second "::"-group.  Witness e.g. x="a", y="::"
;; (-> "a::a"), or the seam witness x=":", y=":" (-> ":::", overlapping so still
;; a single ::-group of length 3).
;;
;; NOTE (solver behavior): default z3 returns sat (correct; witness x="a", y="::").
;; nseq currently returns SPURIOUS UNSAT here -- a soundness bug in the
;; regex-membership x arithmetic-length coupling (same class as the old L2-04
;; Parikh/length bug).  Minimal reproducer (see files/nseq_length_coupling_bug_min.smt2):
;;   x.x in (Sigma* "a" Sigma*) with (= (str.len x) 1)  -> nseq unsat, expected sat.
;; Inequality bounds (|x|>=1) are handled correctly; EXACT equalities trip it.
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun sig-star () (RegEx String) (re.* re.allchar))                 ; Sigma*
(define-fun sig-plus () (RegEx String) (re.+ re.allchar))                 ; Sigma+
(define-fun cc () (RegEx String) (str.to_re "::"))

;; contains "::"
(define-fun has-cc () (RegEx String)
  (re.++ sig-star (re.++ cc sig-star)))
;; contains two separated ::-groups:  Sigma* :: Sigma+ :: Sigma*
(define-fun two-cc () (RegEx String)
  (re.++ sig-star (re.++ cc (re.++ sig-plus (re.++ cc sig-star)))))
;; hex + colon only:  [0-9A-Fa-f:]*
(define-fun hexcol () (RegEx String)
  (re.* (re.union (re.range "0" "9")
        (re.union (re.range "A" "F")
        (re.union (re.range "a" "f") (str.to_re ":"))))))

;; R = has "::"  &  ~(two ::-groups)  &  hex-only
(define-fun R () (RegEx String)
  (re.inter has-cc (re.inter (re.comp two-cc) hexcol)))

;; x.y.x in R, with both variables non-empty
(assert (str.in_re (str.++ x y x) R))
(assert (> (str.len x) 0))
(assert (> (str.len y) 0))

(check-sat)
