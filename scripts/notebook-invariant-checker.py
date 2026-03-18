#!/usr/bin/env python3
"""
Notebook Invariant Checker — Regression Prevention for Jupyter Notebooks in PRs.

This script defines and enforces a set of "invariants" (non-negotiable properties)
for Jupyter notebooks submitted to LLM cookbook repositories. Run it BEFORE and
AFTER every fix to guarantee no previously-fixed bug is accidentally re-introduced.

Origin: Developed during the free-web-search-ultimate PR campaign (Gemini PR #1162,
OpenAI PR #2530) after observing repeated regressions across 6+ review rounds.

Usage:
    python3 scripts/notebook-invariant-checker.py --notebook path/to/notebook.ipynb
    python3 scripts/notebook-invariant-checker.py --config invariants.json

Exit codes:
    0 — All invariants pass (safe to commit)
    1 — One or more invariants failed (do NOT commit)
"""
import argparse
import json
import sys
from pathlib import Path
from typing import Callable, List, Tuple

# ---------------------------------------------------------------------------
# Type aliases
# ---------------------------------------------------------------------------
CheckResult = Tuple[str, bool, str]   # (id, passed, description)
CheckFn = Callable[[dict], List[CheckResult]]

# ---------------------------------------------------------------------------
# Built-in invariant libraries
# ---------------------------------------------------------------------------

def universal_notebook_invariants(nb: dict) -> List[CheckResult]:
    """Invariants that apply to ALL LLM cookbook notebooks.

    Args:
        nb: Parsed notebook dict (from json.load).

    Returns:
        List of (check_id, passed, description) tuples.
    """
    cells = nb.get("cells", [])
    full_text = "\n".join("".join(c.get("source", [])) for c in cells)
    code_cells = [c for c in cells if c.get("cell_type") == "code"]

    return [
        # ── Execution metadata ────────────────────────────────────────────
        ("U1",
         all(c.get("execution_count") is None for c in code_cells),
         "All code cells must have execution_count = null (not run in CI)"),

        # ── No deprecated imports ─────────────────────────────────────────
        ("U2",
         "from free_web_search import search" not in full_text,
         "Must NOT use deprecated 'from free_web_search import search' API"),

        ("U3",
         "UltimateSearcher" in full_text,
         "Must use the UltimateSearcher class from free_web_search.search_web"),

        # ── CLI correctness ───────────────────────────────────────────────
        ("U4",
         # Exclude legitimate occurrences: free-web-search-ultimate (package name),
         # free-web-search-mcp (MCP server command), and free-web-search-ultimate (pip install)
         "free-web-search " not in full_text.replace("free-web-search-ultimate", "").replace("free-web-search-mcp", ""),
         "CLI command must be 'search-web', not the old 'free-web-search'"),

        ("U5",
         "--news" not in full_text or "--type news" in full_text,
         "News CLI flag must be '--type news', not '--news'"),

        # ── Safety guards ─────────────────────────────────────────────────
        ("U6",
         "while True:" not in full_text,
         "Must not use 'while True' in agentic loops (use for+range instead)"),

        # ── Language style ────────────────────────────────────────────────
        ("U7",
         "We'll" not in full_text and "We've" not in full_text and "We're" not in full_text,
         "Must use second-person ('You'll') not first-person ('We'll')"),
    ]


def openai_cookbook_invariants(nb: dict) -> List[CheckResult]:
    """Invariants specific to OpenAI cookbook notebooks.

    Args:
        nb: Parsed notebook dict.

    Returns:
        List of (check_id, passed, description) tuples.
    """
    cells = nb.get("cells", [])
    full_text = "\n".join("".join(c.get("source", [])) for c in cells)

    # Detect setup cell (usually cell index 2)
    setup_src = "".join(cells[2].get("source", [])) if len(cells) > 2 else ""
    tools_src = "".join(cells[4].get("source", [])) if len(cells) > 4 else ""

    return [
        # ── Search function correctness ───────────────────────────────────
        ("O1",
         "_searcher = UltimateSearcher()" in full_text,
         "_searcher must be initialized as UltimateSearcher()"),

        ("O2",
         "_searcher.search(query)" in full_text or "_searcher.search(q" in full_text,
         "search() must delegate to _searcher.search()"),

        ("O3",
         "search_type" in full_text and "news" in full_text,
         "search_news() must pass search_type='news' to _searcher"),

        ("O4",
         "timelimit" in setup_src,
         "search_news() in setup cell must accept optional timelimit param"),

        # ── Tool schema completeness ──────────────────────────────────────
        ("O5",
         '"timelimit"' in tools_src,
         "news_search tool schema must include 'timelimit' field"),

        ("O6",
         "timelimit=tool_input.get" in full_text or "timelimit" in full_text,
         "execute_tool() must forward timelimit to search_news()"),

        # ── Agentic loop safety ───────────────────────────────────────────
        ("O7",
         "for iteration in range(max_iterations):" in full_text,
         "Agentic loop must use for+range(max_iterations), not while True"),

        # ── CLI correctness ───────────────────────────────────────────────
        ("O8",
         'search-web "' in full_text or "search-web '" in full_text,
         "CLI examples must use 'search-web' command"),

        ("O9",
         "--type news" in full_text,
         "CLI news search must use '--type news'"),

        # ── Example gating ────────────────────────────────────────────────
        ("O10",
         "RUN_EXAMPLES = False" in full_text,
         "RUN_EXAMPLES=False guard cell must exist"),

        ("O11",
         full_text.count("if RUN_EXAMPLES:") >= 3,
         "All live example cells (≥3) must be gated behind 'if RUN_EXAMPLES:'"),

        # ── Lazy client construction ──────────────────────────────────────
        ("O12",
         "get_openai_client()" in full_text or "_openai_client" in full_text,
         "OpenAI client must use lazy initialization (not direct OpenAI() at module level)"),

        # ── No signature conflicts ────────────────────────────────────────
        ("O13",
         full_text.count("def search_news") <= 1,
         "search_news must not be redefined in multiple cells (causes signature conflicts)"),
    ]


def gemini_cookbook_invariants(nb: dict) -> List[CheckResult]:
    """Invariants specific to Google Gemini cookbook notebooks.

    Args:
        nb: Parsed notebook dict.

    Returns:
        List of (check_id, passed, description) tuples.
    """
    cells = nb.get("cells", [])
    full_text = "\n".join("".join(c.get("source", [])) for c in cells)
    code_cells = [c for c in cells if c.get("cell_type") == "code"]

    # Check for license cell with cellView=form
    has_license_cell = any(
        "Licensed under the Apache License" in "".join(c.get("source", [])) and
        c.get("metadata", {}).get("cellView") == "form"
        for c in cells
    )

    # Check for helper functions cell with cellView=form
    has_helper_cell = any(
        "Helper Functions" in "".join(c.get("source", [])) and
        c.get("metadata", {}).get("cellView") == "form"
        for c in cells
    )

    return [
        # ── License and copyright ─────────────────────────────────────────
        ("G1",
         has_license_cell,
         "License cell with cellView='form' must exist at top of notebook"),

        ("G2",
         "Copyright" in full_text and "Google LLC" in full_text,
         "Copyright notice (Google LLC) must be present"),

        # ── SDK version ───────────────────────────────────────────────────
        ("G3",
         "from google import genai" in full_text,
         "Must use new SDK: 'from google import genai'"),

        ("G4",
         "google.generativeai" not in full_text,
         "Must NOT use deprecated 'google.generativeai' SDK"),

        # ── Helper functions ──────────────────────────────────────────────
        ("G5",
         has_helper_cell,
         "Helper Functions cell with cellView='form' must exist"),

        ("G6",
         "_format_search_result" in full_text,
         "_format_search_result() helper must exist to avoid code duplication"),

        ("G7",
         "Args:" in full_text and "Returns:" in full_text,
         "All functions must have Google-style docstrings with Args: and Returns:"),

        # ── Automatic function calling ────────────────────────────────────
        ("G8",
         "chats.create" in full_text,
         "Must use client.chats.create() for automatic function calling"),

        # ── Model dropdown ────────────────────────────────────────────────
        ("G9",
         "gemini-2.5-flash" in full_text,
         "MODEL_ID dropdown must include gemini-2.5-flash"),

        # ── Interactive params ────────────────────────────────────────────
        ("G10",
         '# @param {type:"string"}' in full_text,
         "query/question variables must be @param interactive for Colab"),

        # ── API key handling ──────────────────────────────────────────────
        ("G11",
         "YOUR_API_KEY" not in full_text and "YOUR_API_KEY_HERE" not in full_text,
         "Must not contain hardcoded API key placeholders"),

        ("G12",
         "userdata.get" in full_text or "os.environ" in full_text,
         "API key must be read from Colab userdata or os.environ"),
    ]


# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------

def run_checks(label: str, checks: List[CheckResult]) -> List[CheckResult]:
    """Print check results and return list of failures.

    Args:
        label: Human-readable label for this check group.
        checks: List of (id, passed, description) tuples.

    Returns:
        List of failed checks (empty if all pass).
    """
    print(f"\n{'='*60}")
    print(f"  {label}")
    print(f"{'='*60}")
    failures = []
    for check_id, passed, desc in checks:
        icon = "✅" if passed else "❌"
        print(f"  {icon} {check_id}: {desc}")
        if not passed:
            failures.append((check_id, desc))
    if failures:
        print(f"\n  ❌ {len(failures)} invariant(s) FAILED:")
        for fid, fdesc in failures:
            print(f"     - {fid}: {fdesc}")
    else:
        print(f"\n  ✅ All {len(checks)} invariants pass!")
    return failures


def detect_notebook_type(nb: dict, path: str) -> str:
    """Auto-detect whether this is a Gemini, OpenAI, or generic notebook.

    Args:
        nb: Parsed notebook dict.
        path: File path string (used as hint).

    Returns:
        One of 'gemini', 'openai', or 'generic'.
    """
    full_text = "\n".join("".join(c.get("source", [])) for c in nb.get("cells", []))
    path_lower = path.lower()

    if "gemini" in path_lower or "from google import genai" in full_text:
        return "gemini"
    if "openai" in path_lower or "from openai import" in full_text:
        return "openai"
    return "generic"


def check_notebook(path: str) -> int:
    """Run all applicable invariants on a single notebook.

    Args:
        path: Absolute or relative path to the .ipynb file.

    Returns:
        Number of failed invariants (0 = all pass).
    """
    nb_path = Path(path)
    if not nb_path.exists():
        print(f"❌ File not found: {path}")
        return 1

    with open(nb_path) as f:
        nb = json.load(f)

    nb_type = detect_notebook_type(nb, path)
    total_failures = []

    # Always run universal checks
    total_failures += run_checks(
        f"Universal Invariants — {nb_path.name}",
        universal_notebook_invariants(nb)
    )

    # Run type-specific checks
    if nb_type == "openai":
        total_failures += run_checks(
            f"OpenAI-Specific Invariants — {nb_path.name}",
            openai_cookbook_invariants(nb)
        )
    elif nb_type == "gemini":
        total_failures += run_checks(
            f"Gemini-Specific Invariants — {nb_path.name}",
            gemini_cookbook_invariants(nb)
        )

    print(f"\n{'='*60}")
    if not total_failures:
        print(f"  ✅ ALL INVARIANTS PASS — safe to commit!")
    else:
        print(f"  ❌ {len(total_failures)} total failure(s) — DO NOT commit until fixed!")
        for fid, fdesc in total_failures:
            print(f"     - {fid}: {fdesc}")
    print(f"{'='*60}\n")

    return len(total_failures)


def check_multiple_notebooks(paths: List[str]) -> int:
    """Run invariant checks on multiple notebooks.

    Args:
        paths: List of notebook file paths.

    Returns:
        Total number of failures across all notebooks.
    """
    total = 0
    for path in paths:
        total += check_notebook(path)
    return total


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main() -> None:
    """Parse arguments and run the invariant checker."""
    parser = argparse.ArgumentParser(
        description="Notebook Invariant Checker — prevent regressions in LLM cookbook PRs",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Check a single notebook
  python3 scripts/notebook-invariant-checker.py --notebook path/to/notebook.ipynb

  # Check multiple notebooks
  python3 scripts/notebook-invariant-checker.py \\
      --notebook examples/openai_notebook.ipynb \\
      --notebook examples/gemini_notebook.ipynb

  # Auto-discover all notebooks in a directory
  python3 scripts/notebook-invariant-checker.py --dir examples/

Exit codes:
  0 = all invariants pass (safe to commit)
  1 = one or more invariants failed (fix before committing)
        """
    )
    parser.add_argument(
        "--notebook", "-n",
        action="append",
        dest="notebooks",
        metavar="PATH",
        help="Path to a .ipynb notebook file (can be specified multiple times)"
    )
    parser.add_argument(
        "--dir", "-d",
        metavar="DIRECTORY",
        help="Directory to auto-discover all .ipynb files in"
    )

    args = parser.parse_args()

    notebooks = args.notebooks or []

    if args.dir:
        dir_path = Path(args.dir)
        if not dir_path.is_dir():
            print(f"❌ Directory not found: {args.dir}")
            sys.exit(1)
        notebooks += [str(p) for p in dir_path.rglob("*.ipynb")]

    if not notebooks:
        parser.print_help()
        print("\n❌ No notebooks specified. Use --notebook or --dir.")
        sys.exit(1)

    total_failures = check_multiple_notebooks(notebooks)
    sys.exit(0 if total_failures == 0 else 1)


if __name__ == "__main__":
    main()
