"""
analyze_signals.py

Walks every .gd file in a folder and maps signals:
  • signal DECLARATIONS  (signal foo  /  signal foo(params))
  • EMITS                (emit_signal("foo")  /  foo.emit()  /  obj.foo.emit())
  • CONNECTS             (foo.connect(handler)  /  obj.foo.connect(handler))

Output (signal_map.txt) is grouped by signal name and shows:
  - which file/function declares it
  - which file/function emits it
  - which file/function connects it, and to which handler

Limitations (inherent to static analysis):
  - Connections/emits through variables (e.g. `node.sig.connect(...)`)
    record the variable name, not the resolved class – marked with [?]
  - Signals that only appear as string literals in old-style connect()
    are also captured (emit_signal("name") and obj.connect("name", handler))
  - Commented-out lines are skipped
"""

import os
import re
from collections import defaultdict

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPTS_FOLDER = "C:/Users/Isaac/Documents/GitHub/transarctica-2/scripts"
OUTPUT_FILE    = "C:/Users/Isaac/Documents/GitHub/transarctica-2/signal_map.txt"

# ---------------------------------------------------------------------------
# Regexes
# ---------------------------------------------------------------------------

# signal declaration:  signal foo  |  signal foo(a, b)
SIGNAL_DECL_RE = re.compile(r"^\s*signal\s+(\w+)")

# func declaration (to track which function we're inside)
FUNC_DEF_RE = re.compile(r"^\s*(?:static\s+)?func\s+(\w+)\s*[\(:]")

# OLD-STYLE emit:  emit_signal("signal_name", ...)
EMIT_OLD_RE = re.compile(r'\bemit_signal\s*\(\s*"(\w+)"')

# NEW-STYLE emit:  signal_name.emit(...)  OR  obj.signal_name.emit(...)
# Captures everything before .emit() as the "path"
EMIT_NEW_RE = re.compile(r'\b([\w.]+)\.emit\s*\(')

# NEW-STYLE connect:  signal_name.connect(handler)  OR  obj.signal_name.connect(handler)
# Group 1 = path before .connect, Group 2 = handler expression
CONNECT_NEW_RE = re.compile(r'\b([\w.]+)\.connect\s*\(\s*([^)]+?)\s*\)')

# OLD-STYLE connect:  obj.connect("signal_name", handler)
CONNECT_OLD_RE = re.compile(r'\bconnect\s*\(\s*"(\w+)"\s*,\s*([^)]+?)\s*\)')

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _indent_level(line: str) -> int:
    return len(line) - len(line.lstrip("\t"))


def _strip_comment(line: str) -> str:
    """Remove everything after an inline # (but not inside strings, approximately)."""
    # Simple approach: split on # that isn't inside quotes
    in_str = False
    quote_char = None
    for i, ch in enumerate(line):
        if not in_str and ch in ('"', "'"):
            in_str = True
            quote_char = ch
        elif in_str and ch == quote_char:
            in_str = False
        elif not in_str and ch == '#':
            return line[:i]
    return line


def _is_comment_line(line: str) -> bool:
    return line.lstrip().startswith("#")


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------
# signal_db[signal_name] = {
#     "declarations": [(file, line_no, func_context)],
#     "emits":        [(file, line_no, func_context)],
#     "connects":     [(file, line_no, func_context, handler_str)],
# }

# ---------------------------------------------------------------------------
# Pass 1 – collect all declared signal names across all files
# ---------------------------------------------------------------------------

def collect_signal_declarations(folder: str) -> dict:
    """Returns {signal_name: [(filename, lineno)]}"""
    declared = defaultdict(list)
    for root, _, files in os.walk(folder):
        for filename in sorted(files):
            if not filename.endswith(".gd"):
                continue
            full_path = os.path.join(root, filename)
            with open(full_path, "r", encoding="utf-8") as f:
                for lineno, line in enumerate(f, 1):
                    if _is_comment_line(line):
                        continue
                    m = SIGNAL_DECL_RE.match(line)
                    if m:
                        declared[m.group(1)].append((filename, lineno))
    return declared


# ---------------------------------------------------------------------------
# Pass 2 – scan every file for emits and connects
# ---------------------------------------------------------------------------

def _current_func(line: str, prev_func: str | None, prev_indent: int) -> tuple:
    """
    Returns (func_name, func_indent).
    Detects if we've left the previous function body.
    """
    stripped = line.lstrip("\t ")
    m = FUNC_DEF_RE.match(line)
    if m:
        return m.group(1), _indent_level(line)
    # If we hit a non-blank, non-comment line at or shallower than func indent → left func
    if prev_func and stripped and not stripped.startswith("#"):
        if _indent_level(line) <= prev_indent:
            return None, 0
    return prev_func, prev_indent


def scan_file(full_path: str, filename: str, known_signals: set) -> dict:
    """
    Returns {
        "emits":    [(signal_name, lineno, func_context)],
        "connects": [(signal_name, lineno, func_context, handler)],
    }
    """
    emits    = []
    connects = []

    with open(full_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    cur_func   = None
    cur_indent = 0

    for lineno, raw_line in enumerate(lines, 1):
        if _is_comment_line(raw_line):
            continue

        # Track current function
        cur_func, cur_indent = _current_func(raw_line, cur_func, cur_indent)

        code = _strip_comment(raw_line)

        # ---- OLD-STYLE emit:  emit_signal("name", ...) ----
        for m in EMIT_OLD_RE.finditer(code):
            sig = m.group(1)
            if sig in known_signals:
                emits.append((sig, lineno, cur_func or "<module>"))

        # ---- NEW-STYLE emit:  something.emit() ----
        for m in EMIT_NEW_RE.finditer(code):
            path = m.group(1)          # e.g. "unit_arrived_to_tile" or "unit.ap_component.ap_changed"
            sig  = path.split(".")[-1] # the last segment is the signal name
            if sig in known_signals:
                emits.append((sig, lineno, cur_func or "<module>"))

        # ---- NEW-STYLE connect:  something.connect(handler) ----
        for m in CONNECT_NEW_RE.finditer(code):
            path    = m.group(1)
            handler = m.group(2).strip()
            sig     = path.split(".")[-1]
            # Exclude: "connect" is itself a Godot method — skip if sig is not a known signal
            if sig in known_signals:
                connects.append((sig, lineno, cur_func or "<module>", handler))

        # ---- OLD-STYLE connect:  obj.connect("name", handler) ----
        for m in CONNECT_OLD_RE.finditer(code):
            sig     = m.group(1)
            handler = m.group(2).strip()
            if sig in known_signals:
                connects.append((sig, lineno, cur_func or "<module>", handler))

    return {"emits": emits, "connects": connects}


def build_signal_db(folder: str, known_signals: set, declarations: dict) -> dict:
    db = defaultdict(lambda: {"declarations": [], "emits": [], "connects": []})

    # Seed declarations
    for sig, locations in declarations.items():
        for filename, lineno in locations:
            db[sig]["declarations"].append((filename, lineno))

    # Scan every file
    for root, _, files in os.walk(folder):
        for filename in sorted(files):
            if not filename.endswith(".gd"):
                continue
            full_path = os.path.join(root, filename)
            result = scan_file(full_path, filename, known_signals)

            for sig, lineno, func in result["emits"]:
                db[sig]["emits"].append((filename, lineno, func))

            for sig, lineno, func, handler in result["connects"]:
                db[sig]["connects"].append((filename, lineno, func, handler))

    return db


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

def write_report(db: dict, output_file: str) -> None:
    # Build a flat list of (stem, signal_name, info) sorted by stem then signal
    regions = []
    for sig_name, info in db.items():
        decls = info["declarations"]
        if decls:
            for filename, lineno in decls:
                stem = filename[:-3]
                regions.append((stem, sig_name, info))
        else:
            # No declaration found – group under unknown
            regions.append(("unknown", sig_name, info))

    regions.sort(key=lambda r: (r[0], r[1]))

    with open(output_file, "w", encoding="utf-8") as out:
        for stem, sig_name, info in regions:
            emits    = info["emits"]
            connects = info["connects"]

            out.write(f"#region {stem}.{sig_name}\n")

            # Emits
            if emits:
                for filename, lineno, func in sorted(emits, key=lambda x: (x[0], x[2])):
                    estem = filename[:-3]
                    func_label = f"{estem}.{func}()" if func != "<module>" else estem
                    out.write(f"  emitted_by:    {func_label}     [line {lineno}]\n")

            # Connects
            if connects:
                if emits:
                    out.write("\n")
                for filename, lineno, func, handler in sorted(connects, key=lambda x: (x[0], x[2])):
                    cstem = filename[:-3]
                    # Merge connecting file stem with the handler: stem.handler
                    dest = f"{cstem}.{handler}"
                    out.write(f"  connected_to:  {dest}     [line {lineno}]\n")

            if not emits and not connects:
                out.write("  (no emits or connects found)\n")

            out.write("#endregion\n\n")

    print(f"Signal map written to: {output_file}")
    total_sigs     = len(db)
    unconnected    = sum(1 for v in db.values() if not v["connects"])
    unemitted      = sum(1 for v in db.values() if not v["emits"])
    print(f"  Signals declared : {total_sigs}")
    print(f"  Never connected  : {unconnected}")
    print(f"  Never emitted    : {unemitted}")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("Pass 1: collecting signal declarations ...")
    declarations = collect_signal_declarations(SCRIPTS_FOLDER)
    known_signals = set(declarations.keys())
    print(f"  Found {len(known_signals)} declared signals.")

    print("Pass 2: scanning for emits and connects ...")
    db = build_signal_db(SCRIPTS_FOLDER, known_signals, declarations)

    print("Writing report ...")
    write_report(db, OUTPUT_FILE)
