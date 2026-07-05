; L1-05-multi-inter-sat  (divisibility intersection)
; Level 1. x in (aa)* & (aaa)* = (a^6)*: LCM/divisibility intersection. SAT (eps or a^6).
; SAT witness (Sigma={a,b,c}, independently verified by a Brzozowski matcher): x=''
; Status sat is authoritative (concrete witness for sat / by-construction proof for unsat).
; nseq solver behaviour (branch c3, 20s): sat

(set-logic ALL)
(set-info :smt-lib-version 2.6)
(set-info :status sat)
(set-info :category "crafted")
(set-info :source |Graded split-set difficulty benchmark (Level 1) for the "Solving by Splitting" membership solver. Backreference->repeated variable; lookaround/Boolean regex ops (& ~) exercise the split algebra sigma. See paper Theorem 1 and src/ast/rewriter/seq_split.cpp.|)

(declare-fun x () String)

(assert (str.in_re x (re.inter (re.* (str.to_re "aa")) (re.* (str.to_re "aaa")))))

(check-sat)
