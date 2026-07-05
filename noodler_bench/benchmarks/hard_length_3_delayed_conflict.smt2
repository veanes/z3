(set-logic ALL)
(declare-fun x () String)

;; R = (abc)*
(define-fun R_abc () (RegEx String) (re.* (str.to_re "abc")))
(assert (str.in_re x R_abc))

;; Extreme Length Condition
(assert (= (str.len x) 300000002))

;; Why it is hard:
;; Length of x must be a multiple of 3. But 300,000,002 is (3 * 100000000) + 2.
;; A pure structurally guided regex solver will unroll x exactly 100,000,000 times
;; before realizing there is a parity mismatch at the end constraint.
;; The CEGAR length loop should extract the mod 3 rule statically and declare UNSAT
;; purely in the QF_LIA domain before the string unwinder even turns an engine crank.
(check-sat)