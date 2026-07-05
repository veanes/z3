(set-logic ALL)
(set-info :status unsat)
;; ============================================================================
;; Lookaround-inspired membership benchmark  (real npm regex, ECMAScript ranges)
;; Difficulty: L2 -- ALTERNATION over literal UNICODE (Cyrillic) words; a border
;;                   / overlap argument over a repeated variable.
;;
;; Source idiom (a real Belarusian preposition guard from the corpus, of the form
;;   ...(?<! (?:а[бд]?|б[ея]зь?|[дз]а|д?ля|дзеля|[нп]ад?|пр[аы]|празь?|у|церазь?) )...):
;;   a fixed list of short function words. Here we take seven of them literally:
;;     \u043d\u0435 | \u0431\u0435\u0437 | \u043d\u0430\u0434 | \u043f\u0430\u0434 |
;;     \u043f\u0440\u0430\u0437 | \u0434\u043b\u044f | \u0446\u0435\u0440\u0430\u0437\u044c
;;     ( ne | bez | nad | pad | praz | dlya | ceraz' )
;;
;; Membership query (2 variables; x repeated => backreference flavor):
;;     x           in Sigma+                  (x is a non-empty string)
;;     x . y . x   in ( the seven words )
;; Writing a word w as x.y.x with |x|>=1 forces x to be a non-empty BORDER of w
;; (a prefix that is also a suffix) with 2*|x| <= |w|.  None of the seven Cyrillic
;; words has such a border -- none even begins and ends with the same letter --
;; so no x, y work => UNSAT.  The solver must reject every alternative over the
;; wide Cyrillic code-point range.
;;
;; Observed (z3 4.17.0, branch c3):  default = unsat,  nseq = unsat  (both correct).
;; ============================================================================

(declare-fun x () String)
(declare-fun y () String)

(define-fun words () (RegEx String)
  (re.union (str.to_re "\u{43d}\u{435}")                 ; ne
  (re.union (str.to_re "\u{431}\u{435}\u{437}")          ; bez
  (re.union (str.to_re "\u{43d}\u{430}\u{434}")          ; nad
  (re.union (str.to_re "\u{43f}\u{430}\u{434}")          ; pad
  (re.union (str.to_re "\u{43f}\u{440}\u{430}\u{437}")   ; praz
  (re.union (str.to_re "\u{434}\u{43b}\u{44f}")          ; dlya
            (str.to_re "\u{446}\u{435}\u{440}\u{430}\u{437}\u{44c}")))))))) ; ceraz'

;; x is non-empty; the doubled string x . y . x must be one of the words
(assert (str.in_re x (re.+ re.allchar)))
(assert (str.in_re (str.++ x y x) words))

(check-sat)
