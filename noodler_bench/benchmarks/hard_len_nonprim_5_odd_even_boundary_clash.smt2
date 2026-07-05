(set-logic ALL)
(declare-fun x () String)
(declare-fun y () String)
(declare-fun k () Int)
(declare-fun m () Int)

;; R = (ab)*
(define-fun ab () (RegEx String) (str.to_re "ab"))
(define-fun R () (RegEx String) (re.* ab))

;; NON-PRIMITIVE Constraint
(assert (str.in_re (str.++ x y x) R))

;; Exclude empty string trivialities
(assert (> (str.len x) 0))
(assert (> (str.len y) 0))

;; Length constraints
(assert (= (str.len x) (+ (* 2 k) 1))) ;; x is strictly ODD
(assert (>= k 0))
(assert (= (str.len y) (* 2 m)))       ;; y is strictly EVEN
(assert (>= m 0))

;; Why it is spectacularly hard:
;; 1. The total length of `x y x` is 2|x| + |y|.
;; 2. Since |x| is odd, 2|x| is even. Since |y| is even, the total length is EVEN.
;; 3. The CEGAR length abstraction tests the integer bounds and declares SAT! (It correctly recognizes no modulo arithmetic violation for total length).
;; 4. BUT, let's structurally trace the Brzozowski automaton!
;;    - `x y x` belongs to (ab)*, so it perfectly alternates a, b, a, b.
;;    - Suppose `x` starts with `a`. Since $|x|$ is odd, substituting strictly alternating characters implies `x` MUST ALSO end with `a`.
;;    - The subsequence continues into `y`. Since the character preceding `y` was `a`, `y` MUST start with `b`.
;;    - Since $|y|$ is even and alternating, starting with `b` means `y` MUST end with `a`.
;;    - The subsequence continues into the second copy of `x`.
;;    - Since the character preceding it was `a`, the second `x` MUST start with `b`.
;;    - Contradiction! The first instance of `x` started with `a`, but the second instance is forced to start with `b`.
;;    - (Symmetric contradiction exists if `x` starts with `b`).
;; 
;; The string SCC DFS phase tracker must uncover a purely topological structural paradox locked behind non-primitive variable duplication, 
;; while ignoring the false-positive "All clear" flag from the integer length engine!
(check-sat)