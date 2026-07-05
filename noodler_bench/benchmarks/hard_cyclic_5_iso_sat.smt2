(set-logic ALL)
(declare-fun x () String)

;; Same definitions as Benchmark 4, but testing the SAT case.
(define-fun sig-star () (RegEx String) (re.* re.allchar))
(define-fun ab () (RegEx String) (str.to_re "ab"))
(define-fun r1 () (RegEx String) (re.comp (re.++ sig-star (re.++ ab sig-star))))

(define-fun b-star () (RegEx String) (re.* (str.to_re "b")))
(define-fun a-star () (RegEx String) (re.* (str.to_re "a")))
(define-fun r2 () (RegEx String) (re.++ b-star a-star))

(define-fun iso-intersect () (RegEx String) (re.inter r1 r2))

(define-fun len4 () (RegEx String) 
  (re.++ re.allchar (re.++ re.allchar (re.++ re.allchar (re.++ re.allchar sig-star)))))

(define-fun R () (RegEx String) (re.inter iso-intersect len4))

;; Constraint: x x \in R
;; Explicitly matching the paper's equivalence section: u = xx yields SAT.
;; e.g., x = "aa" or x = "bb" is perfectly valid. The solver must find a valid length assignment while traversing the synchronized states of the structurally divergent regex formulas.
(assert (str.in_re (str.++ x x) R))

(check-sat)