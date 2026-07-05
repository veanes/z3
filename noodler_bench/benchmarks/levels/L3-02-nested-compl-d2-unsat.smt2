; L3-02-nested-compl-d2-unsat  (genuine nested complement (d=2))
; Level 3. x.a.x in ~((ab)* . ~((ab)*)): a GENUINE (non-eliminable) inner complement, so the d=2 De Morgan tower cannot be flattened by char-class elimination. The language simplifies to (ab)* (even length only), but x.a.x has odd length 2|x|+1 and so is never in (ab)*. UNSAT.
; Status unsat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): unsat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status unsat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 3) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re (str.++ x "a" x) (re.comp (re.++ (re.* (str.to_re "ab")) (re.comp (re.* (str.to_re "ab")))))))

(check-sat)
