"""
analyze_function_calls.py

Walks a folder of GD (GDScript) files and builds a cross-file call graph.

For every function defined across all .gd files it reports:
  * which user-defined functions it CALLS
  * by which user-defined functions it is CALLED BY

"User-defined" means: any function whose name appears after a "func " keyword
in any of the scanned .gd files.  Built-in Godot functions are NOT filtered out
here by name — they are excluded naturally because they never appear as a
"func " definition in the project files.

Key design decision:
  Functions are keyed by (filename_basename, func_name) to avoid collisions
  between same-named methods in different classes (e.g. enter/exit/update in
  state machine states).  When resolving a call-site token we prefer a function
  in the SAME file first, then fall back to any file that defines it.

Output is written to a plain-ASCII text file so it opens cleanly everywhere.
"""

import os
import re
from collections import defaultdict

# ---------------------------------------------------------------------------
# Regex helpers
# ---------------------------------------------------------------------------

# Matches a func definition line (after lstrip).
# Groups: (1) func_name
FUNC_DEF_RE = re.compile(r"^(?:static\s+)?func\s+(\w+)\s*[\(:]")

# Captures an optional leading dot so we can detect method-on-variable calls.
# Group 1: the dot (present → member access on a variable, skip it)
# Group 2: the identifier
CALL_RE = re.compile(r"(\.)?(\b[A-Za-z_]\w*)\s*\(")


def _func_name_from_line(line: str):
    """Return the function name if the stripped line is a func definition."""
    m = FUNC_DEF_RE.match(line.lstrip("\t "))
    return m.group(1) if m else None


def _indent_level(line: str) -> int:
    """Return the number of leading tab characters."""
    return len(line) - len(line.lstrip("\t"))


# ---------------------------------------------------------------------------
# Data structures
# ---------------------------------------------------------------------------
#
# FuncKey = (file_basename, func_name)
#
# graph[FuncKey] = {
#     "file":       str,          # basename
#     "full_path":  str,
#     "line":       int,
#     "calls":      set[FuncKey],
#     "called_by":  set[FuncKey],
# }

# ---------------------------------------------------------------------------
# Pass 1  —  collect all function definitions
# ---------------------------------------------------------------------------

def collect_definitions(folder_path: str) -> dict:
    definitions = {}   # FuncKey -> info dict

    for root, _, files in os.walk(folder_path):
        for filename in sorted(files):
            if not filename.endswith(".gd"):
                continue
            full_path = os.path.join(root, filename)
            with open(full_path, "r", encoding="utf-8") as f:
                for lineno, line in enumerate(f, start=1):
                    name = _func_name_from_line(line)
                    if name is None:
                        continue
                    key = (filename, name)
                    if key in definitions:
                        # Same file defines the same name twice (rare but warn)
                        print(f"[WARN] {filename}:{name} defined twice; keeping first.")
                        continue
                    definitions[key] = {
                        "file":      filename,
                        "full_path": full_path,
                        "line":      lineno,
                    }

    return definitions


# ---------------------------------------------------------------------------
# Pass 2  —  build the call graph
# ---------------------------------------------------------------------------

def build_call_graph(folder_path: str, definitions: dict) -> dict:
    """
    Returns graph keyed by FuncKey = (filename_basename, func_name).
    """

    # Index: func_name -> list of FuncKeys that carry that name (could be many
    # files, e.g. 'enter' defined in 10 state files)
    name_to_keys: dict[str, list] = defaultdict(list)
    for key in definitions:
        _, func_name = key
        name_to_keys[func_name].append(key)

    # Seed graph
    graph: dict = {}
    for key, info in definitions.items():
        graph[key] = {
            "file":      info["file"],
            "full_path": info["full_path"],
            "line":      info["line"],
            "calls":     set(),
            "called_by": set(),
        }

    for root, _, files in os.walk(folder_path):
        for filename in sorted(files):
            if not filename.endswith(".gd"):
                continue
            full_path = os.path.join(root, filename)

            with open(full_path, "r", encoding="utf-8") as f:
                lines = f.readlines()

            current_key   = None   # FuncKey of the function we're inside
            current_indent = 0

            for line in lines:
                # ---- detect a new func definition ----
                stripped = line.lstrip("\t ")
                name = _func_name_from_line(stripped)
                if name is not None:
                    candidate = (filename, name)
                    if candidate in graph:
                        current_key    = candidate
                        current_indent = _indent_level(line)
                        continue
                    # A func that wasn't in definitions (shouldn't happen)
                    current_key = None
                    continue

                # ---- detect leaving the current func ----
                if current_key is not None:
                    raw = line.rstrip("\n")
                    if raw.strip() and not raw.strip().startswith("#"):
                        if _indent_level(line) <= current_indent:
                            current_key = None

                if current_key is None:
                    continue

                # ---- scan for call tokens ----
                # Strip inline comments
                code_part = stripped.split("#")[0]
                for m in CALL_RE.finditer(code_part):
                    leading_dot = m.group(1)   # "." if this is obj.method(), else None
                    callee_name = m.group(2)

                    if callee_name not in name_to_keys:
                        continue   # not a user-defined function at all

                    candidates = name_to_keys[callee_name]

                    if leading_dot:
                        # This is obj.method() — we can't resolve which object type.
                        # Only keep it if the function name is UNIQUE across the whole
                        # project (exactly one definition), making it unambiguous.
                        # If multiple files define the same name, skip — we'd just add
                        # false positives (e.g. current_state.enter() hitting all states).
                        if len(candidates) != 1:
                            continue
                        # Unique function — safe to attribute
                        resolved = candidates
                    else:
                        # Bare call: prefer same-file definition, else take all matches
                        same_file = [k for k in candidates if k[0] == filename]
                        resolved  = same_file if same_file else candidates

                    for callee_key in resolved:
                        if callee_key != current_key:
                            graph[current_key]["calls"].add(callee_key)

    # ---- back-fill called_by ----
    for caller_key, info in graph.items():
        for callee_key in info["calls"]:
            graph[callee_key]["called_by"].add(caller_key)

    return graph


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

def _fmt_key(key, graph) -> str:
    """Pretty-print a FuncKey as  file_stem.func_name()     [line N]"""
    filename, func_name = key
    line = graph[key]["line"]
    stem = filename[:-3] if filename.endswith(".gd") else filename   # strip .gd
    return f"{stem}.{func_name}()     [line {line}]"


def write_report(graph: dict, output_file: str) -> None:
    # Group by file
    by_file: dict[str, list] = defaultdict(list)
    for key, info in graph.items():
        by_file[info["file"]].append(key)

    with open(output_file, "w", encoding="utf-8") as out:
        for filename in sorted(by_file.keys()):
            out.write(f"#region {filename}\n")

            keys = sorted(by_file[filename], key=lambda k: graph[k]["line"])
            for key in keys:
                _, func_name = key
                info      = graph[key]
                calls     = sorted(info["calls"],     key=lambda k: (k[0], k[1]))
                called_by = sorted(info["called_by"], key=lambda k: (k[0], k[1]))

                out.write(f"  func {func_name}()   [line {info['line']}]\n")

                for c in calls:
                    out.write(f"    -> {_fmt_key(c, graph)}\n")

                if calls and called_by:
                    out.write("\n")

                for c in called_by:
                    out.write(f"    <- {_fmt_key(c, graph)}\n")

                out.write("\n")

            out.write("#endregion\n\n")

        # ---- Orphan functions ----
        orphans = [
            key for key, info in graph.items()
            if not info["calls"] and not info["called_by"]
        ]
        if orphans:
            out.write("#region ORPHANS  (no known calls in or out)\n\n")
            for key in sorted(orphans, key=lambda k: (k[0], k[1])):
                out.write(f"  {_fmt_key(key, graph)}\n")
            out.write("\n#endregion\n")

    print(f"Report written to: {output_file}")
    total   = len(graph)
    orphans_n = sum(1 for k, v in graph.items() if not v["calls"] and not v["called_by"])
    connected = total - orphans_n
    print(f"  Total functions   : {total}")
    print(f"  Connected         : {connected}")
    print(f"  Orphans           : {orphans_n}")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    SCRIPTS_FOLDER = "C:/Users/Isaac/Documents/GitHub/transarctica-2/scripts"
    OUTPUT_FILE    = "C:/Users/Isaac/Documents/GitHub/transarctica-2/call_graph.txt"

    print("Pass 1: collecting function definitions ...")
    definitions = collect_definitions(SCRIPTS_FOLDER)
    print(f"  Found {len(definitions)} user-defined functions.")

    print("Pass 2: building call graph ...")
    graph = build_call_graph(SCRIPTS_FOLDER, definitions)

    print("Writing report ...")
    write_report(graph, OUTPUT_FILE)
