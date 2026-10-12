#!/usr/bin/env python3
"""Yearly data update: World Bank -> Resources/data.plist, with a report.

    python3 Scripts/update_data.py            # dry run: fetch, rebuild, report
    python3 Scripts/update_data.py --apply    # also write the results

What it does:
  1. copies Scripts/shared and Scripts/data to a temporary folder, so a dry
     run leaves the working tree alone;
  2. runs get_data.py (World Bank API) and data.py (builds data.plist,
     merges MANUAL_COUNTRIES) there;
  3. compares the result with Resources/data.plist and prints what changed;
  4. with --apply, copies data.plist to Resources/ and the new CSVs to
     Scripts/data/csv/, then runs check_data.py.

Manual entries (Antarctica, Taiwan, the Holy See and small territories) are
not refreshed: their figures live in MANUAL_COUNTRIES in Scripts/data/data.py
and have to be reviewed by hand, which the report reminds you of.
"""

import argparse
import os
import plistlib
import shutil
import statistics
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCRIPTS = os.path.join(ROOT, "Scripts")
CURRENT = os.path.join(ROOT, "Resources", "data.plist")


def run(args, cwd):
    result = subprocess.run(args, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        sys.stderr.write(result.stdout[-2000:] + result.stderr[-2000:])
        sys.exit(f"{' '.join(args)} failed in {cwd}")
    return result.stdout


def load(path):
    with open(path, "rb") as f:
        return plistlib.load(f)


def manual_countries():
    sys.path.insert(0, os.path.join(SCRIPTS, "data"))
    namespace = {}
    with open(os.path.join(SCRIPTS, "data", "data.py"), encoding="utf-8") as f:
        source = f.read()
    start = source.index("MANUAL_COUNTRIES = {")
    end = source.index("\n}\n", start) + 3
    exec(source[start:end], namespace)
    return set(namespace["MANUAL_COUNTRIES"])


def report(old, new, manual):
    lines = []
    added = sorted(set(new) - set(old))
    removed = sorted(set(old) - set(new))
    lines.append(f"Countries: {len(old)} -> {len(new)}")
    if added:
        lines.append(f"  added:   {', '.join(added)}")
    if removed:
        lines.append(f"  REMOVED: {', '.join(removed)}   <- check these")

    common = [c for c in old if c in new and c not in manual]
    keys = sorted({k for c in common for k in set(old[c]) | set(new[c])})
    lines.append("")
    lines.append(f"{'field':26} {'changed':>8} {'median %':>9} {'appeared':>9} {'vanished':>9}")
    big = []
    for key in keys:
        changed, ratios, appeared, vanished = 0, [], 0, 0
        for c in common:
            a, b = old[c].get(key), new[c].get(key)
            if a == b:
                continue
            changed += 1
            if a is None:
                appeared += 1
            elif b is None:
                vanished += 1
            elif isinstance(a, (int, float)) and a != 0:
                ratio = (b - a) / abs(a) * 100
                ratios.append(ratio)
                big.append((abs(ratio), c, key, a, b))
        if changed:
            median = f"{statistics.median(ratios):+.1f}" if ratios else "-"
            lines.append(f"{key:26} {changed:>8} {median:>9} {appeared:>9} {vanished:>9}")

    lines.append("")
    lines.append("Largest relative changes (worth a look):")
    for _, c, key, a, b in sorted(big, reverse=True)[:12]:
        lines.append(f"  {c:6} {key:24} {a:>16.6g} -> {b:<16.6g}")

    years_old = statistics.median(old[c]["populationYear"] for c in common if "populationYear" in old[c])
    years_new = statistics.median(new[c]["populationYear"] for c in common if "populationYear" in new[c])
    lines.append("")
    lines.append(f"Median population year: {years_old:g} -> {years_new:g}")
    lines.append(f"World population: {old['world']['population']:,} -> {new['world']['population']:,}")

    stale = sorted(manual)
    lines.append("")
    lines.append(f"Manual entries NOT refreshed ({len(stale)}): {', '.join(stale)}")
    lines.append("  Review MANUAL_COUNTRIES in Scripts/data/data.py (figures and years).")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--apply", action="store_true", help="write the results into the project")
    args = parser.parse_args()

    manual = manual_countries()
    with tempfile.TemporaryDirectory() as tmp:
        shutil.copytree(os.path.join(SCRIPTS, "shared"), os.path.join(tmp, "shared"))
        shutil.copytree(os.path.join(SCRIPTS, "data"), os.path.join(tmp, "data"),
                        ignore=shutil.ignore_patterns("__pycache__"))
        work = os.path.join(tmp, "data")

        print("Fetching from the World Bank (a few minutes)...", flush=True)
        run([sys.executable, "get_data.py"], work)
        print("Building data.plist...", flush=True)
        run([sys.executable, "data.py"], work)

        new = load(os.path.join(work, "data.plist"))
        old = load(CURRENT)
        print()
        print(report(old, new, manual))

        if not args.apply:
            print("\nDry run: nothing was written. Use --apply to update the project.")
            return

        shutil.copy(os.path.join(work, "data.plist"), CURRENT)
        shutil.copy(os.path.join(work, "data.plist"), os.path.join(SCRIPTS, "data", "data.plist"))
        for name in os.listdir(os.path.join(work, "csv")):
            shutil.copy(os.path.join(work, "csv", name), os.path.join(SCRIPTS, "data", "csv", name))
        print("\nWritten: Resources/data.plist and Scripts/data/csv/*.csv")

    print("\nRunning check_data.py...")
    status = subprocess.run([sys.executable, os.path.join(SCRIPTS, "check_data.py")]).returncode
    sys.exit(status)


if __name__ == "__main__":
    main()
