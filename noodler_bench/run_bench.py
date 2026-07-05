#!/usr/bin/env python3
"""Run the multivariable regex-membership benchmark suite through several solvers on
one machine (GitHub Actions Ubuntu runner) and emit a per-benchmark results CSV.

Solvers compared (all z3-based, same host => comparable timing):
  * noodler  : the VeriFIT/z3-noodler release binary (Noodler string solver, default)
  * seq      : our z3 with the stock default string solver
  * nseq     : our z3 with smt.string_solver=nseq (the Nielsen path)
  * monadic  : our z3 -v:1 smt.string_solver=nseq, parsing the MONADIC-VERDICT diagnostic

For each solver we record the answer (sat/unsat/unknown/timeout/error), the reported
solver :time in ms (compute-only; for monadic the internal diagnostic timer), and the
wall-clock time in ms.  Authoritative status comes from (set-info :status ...) or the
-sat/-unsat filename suffix.
"""
import subprocess, glob, os, re, csv, time, sys

HERE    = os.path.dirname(os.path.abspath(__file__))
BENCH   = os.environ.get("BENCH_DIR", os.path.join(HERE, "benchmarks"))
Z3      = os.environ.get("Z3_BIN", "./build/z3")
NOODLER = os.environ.get("NOODLER_BIN", "./z3-noodler")
TIMEOUT = int(os.environ.get("BENCH_TIMEOUT", "20"))
OUTCSV  = os.environ.get("OUT_CSV", os.path.join(HERE, "results.csv"))

STATUS_RE = re.compile(r"set-info\s*:status\s+(sat|unsat|unknown)")
TIME_RE   = re.compile(r":time\s+([0-9.]+)")
MON_RE    = re.compile(r"MONADIC-VERDICT (\w+) time-ms ([0-9.]+)")
SOLVED    = {"sat", "unsat"}


def auth(p):
    try:
        txt = open(p, encoding="utf-8", errors="ignore").read()
    except Exception:
        txt = ""
    m = STATUS_RE.search(txt)
    if m and m.group(1) in SOLVED:
        return m.group(1)
    b = os.path.basename(p).lower()
    if "-sat" in b or "_sat" in b:
        return "sat"
    if "-unsat" in b or "_unsat" in b:
        return "unsat"
    return "?"


def run(cmd):
    """Return (combined_output, wall_ms, timed_out)."""
    t0 = time.time()
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=TIMEOUT + 5)
        wall = (time.time() - t0) * 1000.0
        return (p.stdout or "") + "\n" + (p.stderr or ""), wall, False
    except subprocess.TimeoutExpired:
        return "", (TIMEOUT + 5) * 1000.0, True


def parse_ans(out):
    ans = "unknown"
    err = False
    for ln in out.splitlines():
        s = ln.strip()
        if s in ("sat", "unsat", "unknown"):
            ans = s
        elif s.startswith("(error") or s.lower().startswith("error"):
            err = True
    if ans == "unknown" and err:
        return "error"
    return ans


def solver_time_ms(out):
    m = TIME_RE.search(out)
    return round(float(m.group(1)) * 1000.0, 3) if m else ""


def run_answer(cmd):
    out, wall, to = run(cmd)
    if to:
        return "timeout", "", round(wall, 1)
    return parse_ans(out), solver_time_ms(out), round(wall, 1)


def run_monadic(f):
    out, wall, to = run([Z3, "-v:1", f"-T:{TIMEOUT}", "smt.string_solver=nseq", f])
    if to:
        return "timeout", "", round(wall, 1)
    verdict, tms = None, None
    for mm in MON_RE.finditer(out):
        verdict = mm.group(1)   # keep last
        tms = float(mm.group(2))
    if verdict is None:
        return "none", "", round(wall, 1)
    return verdict, round(tms, 3), round(wall, 1)


def main():
    files = sorted(glob.glob(os.path.join(BENCH, "**", "*.smt2"), recursive=True))
    print(f"benchmarks: {len(files)}  z3={Z3}  noodler={NOODLER}  timeout={TIMEOUT}s", flush=True)
    fh = open(OUTCSV, "w", newline="", encoding="utf-8")
    w = csv.writer(fh)
    w.writerow(["file", "auth",
                "noodler_ans", "noodler_ms", "noodler_wall",
                "seq_ans", "seq_ms", "seq_wall",
                "nseq_ans", "nseq_ms", "nseq_wall",
                "monadic_verdict", "monadic_ms", "monadic_wall"])
    for i, f in enumerate(files, 1):
        rel = os.path.relpath(f, BENCH)
        a = auth(f)
        n_ans, n_t, n_w = run_answer([NOODLER, "-st", f"-T:{TIMEOUT}", f])
        s_ans, s_t, s_w = run_answer([Z3, "-st", f"-T:{TIMEOUT}", f])
        q_ans, q_t, q_w = run_answer([Z3, "-st", f"-T:{TIMEOUT}", "smt.string_solver=nseq", f])
        m_v, m_t, m_w = run_monadic(f)
        w.writerow([rel, a, n_ans, n_t, n_w, s_ans, s_t, s_w,
                    q_ans, q_t, q_w, m_v, m_t, m_w])
        fh.flush()
        print(f"[{i}/{len(files)}] {rel:56s} nood={n_ans:7s} seq={s_ans:7s} "
              f"nseq={q_ans:7s} mon={m_v}", flush=True)
    fh.close()
    print(f"wrote {OUTCSV}", flush=True)


if __name__ == "__main__":
    main()
