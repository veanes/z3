; L3-03-nested-compl-d3-sat  (genuine triply-nested complement (d=3))
; Level 3. x.a.x in ~(a* . ~(b* . ~((ab)*))): complement depth d=3 with a GENUINE innermost complement ~((ab)*), so none of the three complement levels can be char-class-eliminated -> the full tower-of-exponentials split blowup is forced. SAT (x=b -> bab).
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x='b'
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 3) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re (str.++ x "a" x) (re.comp (re.++ (re.* (str.to_re "a")) (re.comp (re.++ (re.* (str.to_re "b")) (re.comp (re.* (str.to_re "ab")))))))))

(check-sat)
