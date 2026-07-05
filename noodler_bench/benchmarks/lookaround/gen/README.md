# Generated multivariable regex-membership benchmarks

131 SMT-LIB (`.smt2`, logic `ALL`) benchmarks for the string/regex solver,
produced by [`generate.py`](generate.py). Each benchmark asks whether a **word
equation over string variables with repeated occurrences** (a backreference
flavour) is a member of a regular language built as a Boolean combination
(`re.inter` / `re.comp` / `re.union` / `re.*`) of ECMAScript character classes,
ranges and small literal alternations **mined from
`resharp-node/data/lookarounds.json`** (42,677 real npm regexes).

The repeated variables mimic backreferences (the same substring must occur
several times); the Boolean combinations play the role of the lookarounds
(`(?=…)`, `(?!…)`, `(?<=…)`) that they eliminate.

## Reproduce

```sh
python generate.py        # rewrites *.smt2 and manifest.csv (deterministic)
```

No third-party dependencies; Python's `re` is used at generation time to
*verify* every SAT witness against the actual characters.

## Layout notation

Variables are `x, y, z, w`. A layout names the LHS word, e.g. `xyx = x·y·x`,
`xyzzyx = x·y·z·z·y·x`. Contiguous same-order repetition (`x·y·z·x·y·z`)
collapses to `(xyz)²` and is avoided; layouts are **interleaved** (`xyxzyz`),
**mirrored** (`xyzzyx`) or **adjacency-forcing** (`xxyy`) so the variables
genuinely interact. "All-even" layouts (every variable occurs an even number of
times) are the basis of the parity family.

## Template families

| id  | family     | typical status | idiom (lookaround it replaces)                              |
|-----|------------|----------------|-------------------------------------------------------------|
| T1  | border     | sat / unsat    | keyword alternation `(a\|b\|c)` under anchors               |
| T2  | contains   | sat            | `(?=.*c)` intersected with a class run `(?=[..]+)`          |
| T3  | twosided   | sat            | start-class via look-ahead + end-class via look-behind      |
| T4  | bounded    | sat            | fixed width `{n}` / length-modulo `(?=([..]{k})+)`          |
| T5  | parity     | unsat          | odd-count constraint over an all-even layout                |
| T6  | adjacency  | unsat          | `(?![..][..])` no two adjacent class chars                  |
| T7  | nested     | unsat          | record stream `((?:(?!D).)*D)*` with global `(?!.*D)`       |
| T8  | periodic   | sat            | repetition of a fixed unit `(u)+` / typed pairs `([..][..])+`|
| T9  | conflict   | unsat          | whole-token class vs a disjoint fragment class              |
| T10 | disjoint   | unsat          | two disjoint ranges concatenated (incl. astral / surrogate) |

Difficulty tiers: **L1** easy/decided, **L2** moderate, **L3** hard.
Composition: 16×L1, 70×L2, 45×L3; 72 SAT, 59 UNSAT; 114 two-variable, 17
three-variable.

## Status determination (rigorous)

* **SAT** — a concrete witness is *constructed* and *verified* with Python `re`
  over the real characters. A witness found over a reduced alphabet lifts to the
  full alphabet, so this is sound.
* **UNSAT** — only from a *constructive* argument stated in the file header
  (no non-empty border; parity of a marker under an even-occurrence layout;
  disjoint-class conflict; forced adjacency; every non-empty stream member ends
  with a forbidden delimiter).
* No benchmark relies on a solver's answer to justify its `:status`.

## Manifest

`manifest.csv` — one row per file:

| column       | meaning                                                        |
|--------------|----------------------------------------------------------------|
| `status`     | authoritative annotation (`sat`/`unsat`, see above)            |
| `difficulty` | `L1`/`L2`/`L3`                                                  |
| `default_c3` | z3 default result at `-T:10` (`sat`/`unsat`/`timeout`)         |
| `nseq_c3`    | z3 `smt.string_solver=nseq` result at `-T:10`                  |
| `nseq_class` | `ok` / `bug` / `win` / `timeout` (see below)                   |
| `witness`    | verified witness for SAT files                                 |

`default_c3` / `nseq_c3` were observed with z3 4.17.0 (branch `c3`, build
`7cc5a73bd`) at a **10 s** timeout; the `sat`/`unsat` verdicts are
machine-independent, the `timeout` verdicts are threshold-dependent. Observed on
this set:

* default: 72 sat / 29 unsat / 30 timeout — **0 disagreements with `:status`**.
* `nseq_class`: **ok** 100, **bug** 1, **win** 30, **timeout** 0, where
  * **bug** = nseq returns `unsat` on a SAT benchmark (spurious unsat, an nseq
    soundness bug). Only `t01-border-cssfunc` remains — content coupling
    (`calc` ⇒ x="c"): nseq even derives `y="al"` yet still reports `unsat`.
  * **win** = default times out but nseq closes it — the parity (`t05-*`),
    forced-adjacency (`t06-xyyx*`, `t06-xyzzyx*`) and nested-complement
    (`t07-*`) UNSAT families.

> **History.** An earlier build (`d1b0cbee34`) reported **19** nseq bugs and 20
> nseq timeouts. Three c3 soundness commits — `e8884faa2` (partial-automaton
> soundness), `ed41c2a09` (regex range decomposition) and `7cc5a73bd`
> (string-witness models) — fixed **18 of 19** bugs: the whole `t03-twosided-*`
> (both-ends pinning, ×12) and `t04-mod-*` (length-modulo coupling, ×6) families
> now return `sat`, and all nseq timeouts were eliminated.
