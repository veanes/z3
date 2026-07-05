; L3-01-double-compl-sat  (double complement (d=2))
; Level 3. x.a.x in ~(~(contains aa)): complement depth d=2; sigma expands ~(~S) to a 2^(2^k) fold before simplification. Language = contains aa. SAT (x=a -> aaa).
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x='a'
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 3) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re (str.++ x "a" x) (re.comp (re.comp (re.++ (re.* re.allchar) (str.to_re "aa") (re.* re.allchar))))))

(check-sat)
