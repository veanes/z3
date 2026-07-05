# Hard lookbehind / nested-lookaround membership benchmarks

`119` SMT-LIB (`.smt2`, logic `ALL`) benchmarks for the string/regex solver that
**stress the split algebra** (`src/ast/rewriter/seq_split.{h,cpp}` — the `sigma`
"Solving by Splitting" decomposition used by `theory_nseq` via
`seq_nielsen.cpp`). Produced by [`generate.py`](generate.py); observed columns
added by [`validate.py`](validate.py).

Each benchmark is a **word equation over string variables with repeated
occurrences** (a backreference flavour) asserted to be a member of a language
built from **lookbehind / negative-lookbehind / nested-lookaround** idioms mined
from `resharp-node/data/lookarounds.json` (42,677 real npm regexes: 5,360 with
negative lookbehind, 7,955 positive, 1,211 nesting a lookahead inside a
lookbehind).

## Why lookbehinds stress splitting

A lookaround is a zero-width assertion; against a whole-string membership it
becomes a Boolean-closure operation on the surrounding language:

| lookaround (at a point splitting the word into `A`·`B`) | language |
|---|---|
| `A (?<=L) B`  positive lookbehind  | `(A ∩  Σ*·L )·B` |
| `A (?<!L) B`  **negative lookbehind** | `(A ∩ ~(Σ*·L))·B` |
| `A (?=M)  B`  positive lookahead   | `A·(B ∩  M·Σ* )` |
| `A (?!M)  B`  negative lookahead   | `A·(B ∩ ~(M·Σ*))` |

With `A = Σ*`, a **negative lookbehind at the start**, `(?<!L) R`, becomes
`~(Σ*·L)·R` — a **complement concatenated on the right** with a regex. In the
split algebra that is `rcat(compl(sigma(Σ*·L)), R)`, which drives the `compl`
De Morgan expansion and the `rcat` distribution (the "splitting" path). Nesting,
intersection, and two-sided flanks multiply the split-set cardinality.

## Template families

| id  | family    | status | idiom (lookaround it eliminates)                          | typically hard for |
|-----|-----------|--------|-----------------------------------------------------------|--------------------|
| L11 | nlb       | sat    | `(?<!L) C+`  →  `~(Σ*·L)·C+`                               | neither (coverage) |
| L12 | flank     | sat    | `(?<!L) C+ (?!M)`  →  `~(Σ*·L)·C+·~(M·Σ*)`                 | neither (coverage) |
| L13 | inter     | sat    | `AND_i (?<!Lᵢ) C+` (k simultaneous neg-lookbehinds)       | **default** (∝ k)  |
| L14 | conflict  | unsat  | `(?<!L) … R{m}$` with the token forced into a disjoint class | **default**     |
| L15 | negcount  | sat    | `¬( token = C{m} sep C{m} )` (negative lookaround, counting)  | **nseq** (split blow-up) |
| L16 | nest      | sat    | `(?<!(~(Σ*·L)·M)) C+` (neg-lookbehind whose context is one) | neither (coverage) |

Layouts (repeated-variable shapes): `xyx`, `xyyx`, `xyxy`, … . Difficulty tiers
**L2** (moderate) / **L3** (hard). The suite is deliberately weighted toward L3.

## Status determination (rigorous)

* **SAT** — a concrete witness is **constructed and verified** by an exact
  Brzozowski-derivative membership evaluator embedded in `generate.py` that
  supports the full algebra used here (intersection, **complement**, bounded
  **loop**). Deciding a concrete string is alphabet-independent, so a verified
  witness is sound over the full Unicode alphabet.
* **UNSAT** — from a **constructive argument** in the file header (the word must
  end with `R{m}` over one class, but the layout ends in a variable pinned to a
  disjoint class), plus a bounded no-witness check in `generate.py`.
* No benchmark relies on a solver's answer to justify its `:status`.

## Reproduce

```sh
python generate.py            # writes *.smt2 + manifest.csv (deterministic)
python validate.py [z3path]   # adds default_c3 / nseq_c3 / nseq_class columns
```

## Manifest

`manifest.csv` — one row per file: `file, family, layout, nvars, difficulty,
status, default_c3, nseq_c3, nseq_class, witness, note`.

* `default_c3` / `nseq_c3` — z3 (branch `c3`, build `7cc5a73bd`) default vs
  `smt.string_solver=nseq`, each at `-T:10`.
* `nseq_class` — `ok` (nseq decided, default too) / `win` (default timed out,
  nseq decided) / `bug` (nseq contradicts `:status` — a soundness bug) /
  `timeout` (nseq did not decide).

<!-- OBSERVED -->
## Observed (z3 c3 `7cc5a73bd`, `-T:10`)

119 files — **83 sat / 36 unsat** (`:status`); composition **47 L2 / 72 L3**,
nlb 16, flank 16, inter 12, conflict 36, negcount 27, nest 12.

* **default**: 83 sat / 36 timeout — **0 disagreements with `:status`**.
* **nseq**: 56 sat / 36 unsat / 27 timeout.
* **nseq_class**: **ok** 56, **win** 36, **timeout** 27, **bug** 0, where
  * **win** (36) = the whole **L14 conflict** family: default times out, nseq
    closes it `unsat` — nseq is strong on complement-concat + disjoint-class.
  * **timeout** (27) = the whole **L15 negcount** family: nseq's split/DFS
    blows up on the complement of a bounded loop (Failure Mode 1), while default
    answers `sat` quickly. These are the prime split-algebra optimisation targets.

The **L15 negcount** files scale with the loop bound `m` (2/3/4) and are the
intended stressors for split-algebra performance work; **L14 conflict** exercises
`compl`+`rcat` on the default (seq) solver.
