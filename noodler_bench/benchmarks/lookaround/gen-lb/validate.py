#!/usr/bin/env python3
"""Validate the gen-lb benchmark suite and enrich manifest.csv with observed
columns.  Runs z3 default (authoritative) and smt.string_solver=nseq at -T:10
over every *.smt2 listed in manifest.csv, then rewrites manifest.csv with
default_c3 / nseq_c3 / nseq_class added.

Usage:  python validate.py [path-to-z3]
        (default z3: C:\\git\\z3\\build\\release\\z3.exe or $env:Z3)

nseq_class:  ok   = nseq decided correctly and default also decided
             win  = default timed out but nseq decided correctly
             bug  = nseq contradicts the (constructive) :status  <-- soundness bug
             timeout = nseq did not decide (unknown/timeout)
The default column is authoritative: any default disagreement with :status is a
generator error and is reported loudly.
"""
import csv, os, re, subprocess, sys
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
MAN = os.path.join(HERE, "manifest.csv")
Z3 = (sys.argv[1] if len(sys.argv) > 1 else
      os.environ.get("Z3", r"C:\git\z3\build\release\z3.exe"))
T = 10
HARD_KILL = 25
VERDICT = re.compile(r"^(sat|unsat|unknown|timeout)$")

def run(path, nseq):
    args = [Z3, f"-T:{T}"] + (["smt.string_solver=nseq"] if nseq else []) + [path]
    try:
        p = subprocess.run(args, capture_output=True, text=True, timeout=HARD_KILL)
        out = (p.stdout or "") + "\n" + (p.stderr or "")
    except subprocess.TimeoutExpired:
        return "timeout", False
    verdict = None
    for line in out.splitlines():
        if VERDICT.match(line.strip()): verdict = line.strip()
    if verdict is None:
        verdict = "timeout" if "timeout" in out else "unknown"
    return verdict, ("check annotation" in out)

def classify(status, dv, nv):
    if nv in ("timeout", "unknown"): return "timeout"
    if nv == status: return "ok" if dv in ("sat", "unsat") else "win"
    return "bug"

def main():
    rows = list(csv.DictReader(open(MAN, encoding="utf-8")))
    n = len(rows)
    out = []
    for i, r in enumerate(rows, 1):
        f = os.path.join(HERE, r["file"])
        dv, _ = run(f, False)
        nv, nmis = run(f, True)
        cls = classify(r["status"], dv, nv)
        nseq_c3 = "spurious-unsat" if cls == "bug" and nv == "unsat" else nv
        r2 = dict(r); r2["default_c3"] = dv; r2["nseq_c3"] = nseq_c3; r2["nseq_class"] = cls
        out.append(r2)
        flag = "  <-- DEFAULT DISAGREES!" if dv in ("sat","unsat") and dv != r["status"] else ""
        print(f"[{i}/{n}] {r['file']:44s} :status={r['status']:5s} default={dv:8s} nseq={nv:8s} {cls}{flag}", flush=True)

    cols = ["file","family","layout","nvars","difficulty","status",
            "default_c3","nseq_c3","nseq_class","witness","note"]
    with open(MAN, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=cols); w.writeheader()
        for r in out: w.writerow({k: r.get(k, "") for k in cols})

    dis = [r for r in out if r["default_c3"] in ("sat","unsat") and r["default_c3"] != r["status"]]
    print("\n==== SUMMARY ====")
    print("default:", dict(Counter(r["default_c3"] for r in out)))
    print("nseq   :", dict(Counter(r["nseq_c3"] for r in out)))
    print("class  :", dict(Counter(r["nseq_class"] for r in out)))
    print(f"default disagreements with :status = {len(dis)}"
          + ("" if not dis else "  *** GENERATOR ERROR ***"))
    for r in dis: print("   ", r["file"], r["status"], "->", r["default_c3"])
    bugs = [r["file"] for r in out if r["nseq_class"] == "bug"]
    if bugs:
        print("nseq spurious-unsat (soundness bug triggers):")
        for b in bugs: print("   ", b)

if __name__ == "__main__":
    main()
