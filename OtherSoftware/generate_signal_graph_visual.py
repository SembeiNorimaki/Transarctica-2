"""
generate_signal_graph_visual.py

Parses signal_map.txt and generates a canvas-based interactive HTML file.

  Nodes  = GD file stems, arranged in columns by category
  Edges  = file-to-file connections via signals (aggregated by pair)
  Hover  = highlights neighbours + tooltip listing signal names
  Filter = per-category highlight buttons

Re-run whenever signal_map.txt changes.
"""

import re
import json
from pathlib import Path
from collections import defaultdict

INPUT_FILE  = Path("C:/Users/Isaac/Documents/GitHub/transarctica-2/signal_map.txt")
OUTPUT_FILE = Path("C:/Users/Isaac/Documents/GitHub/transarctica-2/signal_graph_visual.html")

# ─── Parsing ──────────────────────────────────────────────────────────────────

REGION_RE    = re.compile(r"^#region (.+)$")
EMITTED_RE   = re.compile(r"^\s+emitted_by:\s+(\S+)\s+\[line")
CONNECTED_RE = re.compile(r"^\s+connected_to:\s+(\S+)\s+\[line")


def _file_of(expr: str) -> str:
    """'ap_component.use_ap()' → 'ap_component'"""
    return expr.rstrip("()").split(".")[0]


def _signal_of(region_label: str) -> str:
    """'ap_component.ap_changed' → 'ap_changed'"""
    parts = region_label.split(".", 1)
    return parts[1] if len(parts) > 1 else region_label


def parse_signal_map(path: Path):
    """Returns list of {signal, from_file, to_file}."""
    rows = []
    cur_sig = None
    emitters, receivers = [], []

    def flush():
        if cur_sig:
            for e in emitters:
                for r in receivers:
                    rows.append({"signal": _signal_of(cur_sig), "from": e, "to": r})

    for line in path.read_text(encoding="utf-8").splitlines():
        m = REGION_RE.match(line)
        if m:
            flush()
            cur_sig = m.group(1).strip()
            emitters, receivers = [], []
            continue

        if line.startswith("#endregion"):
            flush()
            cur_sig = None
            emitters, receivers = [], []
            continue

        if not cur_sig:
            continue

        m = EMITTED_RE.match(line)
        if m:
            f = _file_of(m.group(1))
            if f not in emitters:
                emitters.append(f)
            continue

        m = CONNECTED_RE.match(line)
        if m:
            r = _file_of(m.group(1))
            if r not in receivers:
                receivers.append(r)

    flush()
    return rows


# ─── Categorisation ───────────────────────────────────────────────────────────

CATEGORY_ORDER = [
    "Scenes", "Managers", "Services", "Components",
    "Entities", "Inventories", "UI", "State Machines",
]

CAT_COLORS_LIGHT = {
    "Scenes":         {"fill": "#EEF2FF", "stroke": "#4338CA", "text": "#3730A3"},
    "Managers":       {"fill": "#E6F1FB", "stroke": "#185FA5", "text": "#0C447C"},
    "Services":       {"fill": "#E1F5EE", "stroke": "#0F6E56", "text": "#085041"},
    "Components":     {"fill": "#FEF3C7", "stroke": "#B45309", "text": "#78350F"},
    "Entities":       {"fill": "#F5F3FF", "stroke": "#7C3AED", "text": "#5B21B6"},
    "Inventories":    {"fill": "#FDF2F8", "stroke": "#BE185D", "text": "#9D174D"},
    "UI":             {"fill": "#FFF7ED", "stroke": "#C2410C", "text": "#9A3412"},
    "State Machines": {"fill": "#F0FDF4", "stroke": "#15803D", "text": "#14532D"},
    "Other":          {"fill": "#F1EFE8", "stroke": "#5F5E5A", "text": "#444441"},
}

CAT_COLORS_DARK = {
    "Scenes":         {"fill": "#1E1B4B", "stroke": "#818CF8", "text": "#A5B4FC"},
    "Managers":       {"fill": "#0C2340", "stroke": "#60A5FA", "text": "#93C5FD"},
    "Services":       {"fill": "#052E20", "stroke": "#34D399", "text": "#6EE7B7"},
    "Components":     {"fill": "#2D1B00", "stroke": "#FCD34D", "text": "#FDE68A"},
    "Entities":       {"fill": "#1E0A3D", "stroke": "#A78BFA", "text": "#C4B5FD"},
    "Inventories":    {"fill": "#2D0A1E", "stroke": "#F472B6", "text": "#FBCFE8"},
    "UI":             {"fill": "#2D1208", "stroke": "#FB923C", "text": "#FED7AA"},
    "State Machines": {"fill": "#052210", "stroke": "#4ADE80", "text": "#BBF7D0"},
    "Other":          {"fill": "#1C1C1A", "stroke": "#9CA3AF", "text": "#D1D5DB"},
}


def categorise(stem: str) -> str:
    s = stem.lower()
    if s.endswith("_scene"):
        return "Scenes"
    if s.endswith("_manager") or s in ("faction_ai", "pod_ai_manager", "selection_manager"):
        return "Managers"
    if s.endswith("_service"):
        return "Services"
    if s.endswith("_component"):
        return "Components"
    if s.endswith("_inventory"):
        return "Inventories"
    if s.endswith("_hud") or s.endswith("_ui") or s in ("trade_menu", "ui_wasd"):
        return "UI"
    if ("_state" in s or "_behavior" in s or "_action" in s
            or s == "unit_ai" or "state_machine" in s):
        return "State Machines"
    return "Entities"


# ─── Build graph ──────────────────────────────────────────────────────────────

NODE_W, NODE_H, NODE_GAP = 168, 32, 8
COL_GAP = 48
HEADER_H = 40


def build_graph(rows):
    # Aggregate (from, to) → set of signal names
    edge_map = defaultdict(set)
    all_files = set()
    for r in rows:
        if r["from"] == r["to"]:
            continue
        edge_map[(r["from"], r["to"])].add(r["signal"])
        all_files.add(r["from"])
        all_files.add(r["to"])

    # Group by category
    by_cat = defaultdict(list)
    for f in sorted(all_files):
        by_cat[categorise(f)].append(f)

    # Compute positions – one column per category
    positions = {}
    x = 20
    for cat in CATEGORY_ORDER:
        if cat not in by_cat:
            continue
        y = HEADER_H
        for stem in by_cat[cat]:
            positions[stem] = {"x": x, "y": y, "cat": cat}
            y += NODE_H + NODE_GAP
        x += NODE_W + COL_GAP

    canvas_w = x + 10
    canvas_h = (
        max(
            HEADER_H + len(by_cat.get(cat, [])) * (NODE_H + NODE_GAP)
            for cat in CATEGORY_ORDER if cat in by_cat
        ) + 30
        if by_cat else 200
    )

    nodes = [
        {"id": s, "label": s, "cat": pos["cat"],
         "x": pos["x"], "y": pos["y"]}
        for s, pos in sorted(positions.items())
    ]

    edges = [
        {"f": f, "t": t, "signals": sorted(sigs)}
        for (f, t), sigs in sorted(edge_map.items())
    ]

    return nodes, edges, dict(by_cat), canvas_w, canvas_h


# ─── HTML helpers ─────────────────────────────────────────────────────────────

def filter_buttons(by_cat):
    btns = ['<button class="filter-btn active" onclick="setFilter(\'all\')">All</button>']
    for cat in CATEGORY_ORDER:
        if cat in by_cat:
            btns.append(
                f'<button class="filter-btn" onclick="setFilter({json.dumps(cat)})">{cat}</button>'
            )
    return "\n  ".join(btns)


def legend_html(by_cat):
    items = []
    for cat in CATEGORY_ORDER:
        if cat not in by_cat:
            continue
        col = CAT_COLORS_LIGHT[cat]["stroke"]
        items.append(
            f'<div class="leg"><div class="leg-dot" style="background:{col}"></div>{cat}</div>'
        )
    return "\n  ".join(items)


# ─── Generate HTML ────────────────────────────────────────────────────────────

def generate_html(nodes, edges, by_cat, canvas_w, canvas_h):
    # Use a marker-substitution approach to avoid f-string / JS brace conflicts
    html = HTML_TEMPLATE
    html = html.replace("<<<FILTER_BUTTONS>>>", filter_buttons(by_cat))
    html = html.replace("<<<LEGEND>>>",         legend_html(by_cat))
    html = html.replace("<<<NODES_JSON>>>",      json.dumps(nodes))
    html = html.replace("<<<EDGES_JSON>>>",      json.dumps(edges))
    html = html.replace("<<<CAT_L_JSON>>>",      json.dumps(CAT_COLORS_LIGHT))
    html = html.replace("<<<CAT_D_JSON>>>",      json.dumps(CAT_COLORS_DARK))
    html = html.replace("<<<NODE_W>>>",          str(NODE_W))
    html = html.replace("<<<NODE_H>>>",          str(NODE_H))
    html = html.replace("<<<CANVAS_W>>>",        str(canvas_w))
    html = html.replace("<<<CANVAS_H>>>",        str(canvas_h))
    return html


# ─── HTML template (pure string, no f-string) ─────────────────────────────────

HTML_TEMPLATE = """\
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Signal Graph</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:#f8f8f6;color:#1a1a18;font-size:13px}
@media(prefers-color-scheme:dark){
  body{background:#111110;color:#e8e6e0}
}
.toolbar{display:flex;align-items:center;gap:8px;padding:10px 16px;flex-wrap:wrap;
         border-bottom:1px solid #e0ddd6;background:#fff}
@media(prefers-color-scheme:dark){
  .toolbar{background:#1a1a18;border-bottom-color:#2e2e2a}
}
h1{font-size:14px;font-weight:600;color:#333;margin-right:6px;white-space:nowrap}
@media(prefers-color-scheme:dark){h1{color:#e0ddd6}}
.filter-btn{padding:3px 11px;border-radius:14px;border:1px solid #ccc;background:transparent;
            font-size:12px;cursor:pointer;color:#555;transition:all .15s}
.filter-btn.active{color:#fff;border-color:transparent;background:#185FA5}
.filter-btn:hover:not(.active){border-color:#888;color:#222}
@media(prefers-color-scheme:dark){
  .filter-btn{border-color:#3a3a36;color:#999}
  .filter-btn.active{background:#3b82f6}
  .filter-btn:hover:not(.active){border-color:#777;color:#eee}
}
.wrap{position:relative;overflow-x:auto;overflow-y:hidden}
canvas{display:block;cursor:default}
.tooltip{position:fixed;background:#fff;border:1px solid #ddd;border-radius:8px;
         padding:10px 14px;font-size:12px;pointer-events:none;display:none;
         max-width:270px;z-index:100;line-height:1.75;
         box-shadow:0 4px 20px rgba(0,0,0,.12)}
.tooltip b{display:block;font-weight:600;font-size:13px;margin-bottom:2px}
.tip-cat{color:#888;font-size:11px;margin-bottom:6px}
.tip-sec{font-weight:600;margin-top:6px;margin-bottom:2px;font-size:11px;
         text-transform:uppercase;letter-spacing:.04em;color:#666}
.tip-row{color:#333;padding-left:6px}
.tip-sig{color:#777;padding-left:18px;font-size:11px}
@media(prefers-color-scheme:dark){
  .tooltip{background:#1e1e1c;border-color:#3a3a36;color:#ddd;
           box-shadow:0 4px 20px rgba(0,0,0,.6)}
  .tip-cat{color:#777}
  .tip-sec{color:#888}
  .tip-row{color:#ccc}
  .tip-sig{color:#666}
}
.legend{display:flex;flex-wrap:wrap;gap:10px;padding:10px 16px;font-size:11px;
        color:#777;border-top:1px solid #e0ddd6;background:#fff}
@media(prefers-color-scheme:dark){
  .legend{background:#1a1a18;border-top-color:#2e2e2a;color:#888}
}
.leg{display:flex;align-items:center;gap:5px}
.leg-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0}
</style>
</head>
<body>

<div class="toolbar">
  <h1>&#9889; Signal Flow</h1>
  <<<FILTER_BUTTONS>>>
</div>

<div class="wrap">
  <canvas id="c"></canvas>
  <div class="tooltip" id="tip"></div>
</div>

<div class="legend">
  <<<LEGEND>>>
</div>

<script>
const DARK = matchMedia('(prefers-color-scheme:dark)').matches;
const CAT_L = <<<CAT_L_JSON>>>;
const CAT_D = <<<CAT_D_JSON>>>;
const C = DARK ? CAT_D : CAT_L;

const NW = <<<NODE_W>>>, NH = <<<NODE_H>>>;
const FULL_W = <<<CANVAS_W>>>, FULL_H = <<<CANVAS_H>>>;

const NODES = <<<NODES_JSON>>>;
const EDGES = <<<EDGES_JSON>>>;

// index
const nodeMap = {};
NODES.forEach(n => nodeMap[n.id] = n);

// adjacency: node_id → [{edgeIdx, other}]
const adj = {};
NODES.forEach(n => adj[n.id] = []);
EDGES.forEach((e, i) => {
  (adj[e.f] = adj[e.f]||[]).push({i, other:e.t, dir:'out'});
  (adj[e.t] = adj[e.t]||[]).push({i, other:e.f, dir:'in'});
});

// canvas setup
const canvas = document.getElementById('c');
const DPR = window.devicePixelRatio || 1;
canvas.width  = FULL_W * DPR;
canvas.height = FULL_H * DPR;
canvas.style.width  = FULL_W + 'px';
canvas.style.height = FULL_H + 'px';
const ctx = canvas.getContext('2d');
ctx.scale(DPR, DPR);

let activeFilter = 'all';
let hovered = null;

// ── filter ───────────────────────────────────────────────
function setFilter(f) {
  activeFilter = f;
  document.querySelectorAll('.filter-btn').forEach(b => {
    const lbl = b.textContent.trim();
    b.classList.toggle('active', (f==='all'&&lbl==='All') || lbl===f);
  });
  draw();
}

function nodeAlpha(n) {
  if (activeFilter === 'all') return 1;
  return n.cat === activeFilter ? 1 : 0.12;
}

function edgeAlpha(e) {
  if (activeFilter === 'all') return 0.28;
  const fn = nodeMap[e.f], tn = nodeMap[e.t];
  if (!fn||!tn) return 0;
  return (fn.cat===activeFilter||tn.cat===activeFilter) ? 0.65 : 0.04;
}

// ── drawing ──────────────────────────────────────────────
function drawEdge(x1,y1,x2,y2, strokeCol, alpha, thick) {
  ctx.globalAlpha = alpha;
  const mx = (x1+x2)/2;
  ctx.beginPath();
  ctx.moveTo(x1,y1);
  ctx.bezierCurveTo(mx,y1, mx,y2, x2,y2);
  ctx.strokeStyle = strokeCol;
  ctx.lineWidth = thick;
  ctx.stroke();
  // arrowhead
  const angle = Math.atan2(y2-y1, x2-x1);
  const ah = thick > 1 ? 7 : 5;
  ctx.beginPath();
  ctx.moveTo(x2,y2);
  ctx.lineTo(x2-ah*Math.cos(angle-0.38), y2-ah*Math.sin(angle-0.38));
  ctx.lineTo(x2-ah*Math.cos(angle+0.38), y2-ah*Math.sin(angle+0.38));
  ctx.closePath();
  ctx.fillStyle = strokeCol;
  ctx.fill();
  ctx.globalAlpha = 1;
}

function draw() {
  ctx.clearRect(0,0,FULL_W,FULL_H);

  const hovSet = hovered ? new Set(adj[hovered].map(a=>a.i)) : null;

  // column headers
  ctx.font = '500 11px Segoe UI,system-ui,sans-serif';
  ctx.textBaseline = 'top';
  const seen = new Set();
  NODES.forEach(n => {
    if (seen.has(n.cat)) return;
    seen.add(n.cat);
    ctx.globalAlpha = 0.55;
    ctx.fillStyle = (C[n.cat]||C.Other).stroke;
    ctx.textAlign = 'left';
    ctx.fillText(n.cat, n.x, 10);
  });
  ctx.globalAlpha = 1;

  // edges
  EDGES.forEach((e,i) => {
    const fp = nodeMap[e.f], tp = nodeMap[e.t];
    if (!fp||!tp) return;
    const x1 = fp.x+NW, y1 = fp.y+NH/2;
    const x2 = tp.x,    y2 = tp.y+NH/2;
    const isHov = hovSet && hovSet.has(i);
    const baseAlpha = edgeAlpha(e);
    const col = isHov ? (C[fp.cat]||C.Other).stroke
                      : (DARK ? '#4a4a45' : '#c0bdb6');
    drawEdge(x1,y1,x2,y2, col,
             isHov ? Math.min(baseAlpha*2.2,0.95) : baseAlpha,
             isHov ? 1.8 : 0.8);
  });

  // nodes
  NODES.forEach(n => {
    const col = C[n.cat]||C.Other;
    const isHov = hovered===n.id;
    ctx.globalAlpha = nodeAlpha(n);

    ctx.beginPath();
    ctx.roundRect(n.x, n.y, NW, NH, 6);
    ctx.fillStyle = col.fill;
    ctx.fill();
    ctx.strokeStyle = isHov ? col.stroke : col.stroke+'77';
    ctx.lineWidth = isHov ? 1.8 : 0.6;
    ctx.stroke();

    ctx.fillStyle = col.text;
    ctx.font = (isHov?'500':'400')+' 12px Segoe UI,system-ui,sans-serif';
    ctx.textBaseline = 'middle';
    ctx.textAlign = 'center';
    ctx.fillText(n.label, n.x+NW/2, n.y+NH/2, NW-12);
  });

  ctx.globalAlpha = 1;
}

// ── tooltip / hover ──────────────────────────────────────
canvas.addEventListener('mousemove', ev => {
  const rect = canvas.getBoundingClientRect();
  const mx = ev.clientX - rect.left;
  const my = ev.clientY - rect.top;

  let found = null;
  for (const n of NODES) {
    if (mx>=n.x && mx<=n.x+NW && my>=n.y && my<=n.y+NH) { found=n.id; break; }
  }

  hovered = found;
  canvas.style.cursor = found ? 'pointer' : 'default';
  draw();

  const tip = document.getElementById('tip');
  if (!found) { tip.style.display='none'; return; }

  const node = nodeMap[found];
  const outEdges = EDGES.filter(e => e.f===found);
  const inEdges  = EDGES.filter(e => e.t===found);

  let html = `<b>${node.label}</b><div class="tip-cat">${node.cat}</div>`;

  if (outEdges.length) {
    html += '<div class="tip-sec">Emits to</div>';
    outEdges.forEach(e => {
      html += `<div class="tip-row">→ ${e.t}</div>`;
      e.signals.forEach(s => html += `<div class="tip-sig">${s}</div>`);
    });
  }
  if (inEdges.length) {
    html += '<div class="tip-sec">Receives from</div>';
    inEdges.forEach(e => {
      html += `<div class="tip-row">← ${e.f}</div>`;
      e.signals.forEach(s => html += `<div class="tip-sig">${s}</div>`);
    });
  }

  tip.innerHTML = html;
  tip.style.display = 'block';

  // position (keep on-screen)
  const TW=tip.offsetWidth, TH=tip.offsetHeight;
  const VW=window.innerWidth, VH=window.innerHeight;
  let tx = ev.clientX+14, ty = ev.clientY+10;
  if (tx+TW>VW) tx = ev.clientX-TW-14;
  if (ty+TH>VH) ty = ev.clientY-TH-10;
  tip.style.left = tx+'px';
  tip.style.top  = ty+'px';
});

canvas.addEventListener('mouseleave', () => {
  hovered=null;
  document.getElementById('tip').style.display='none';
  draw();
});

draw();
</script>
</body>
</html>
"""


# ─── Entry point ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print(f"Parsing {INPUT_FILE} ...")
    rows = parse_signal_map(INPUT_FILE)
    print(f"  {len(rows)} signal flow rows found.")

    nodes, edges, by_cat, canvas_w, canvas_h = build_graph(rows)
    print(f"  {len(nodes)} file nodes, {len(edges)} file-to-file edges.")

    html = generate_html(nodes, edges, by_cat, canvas_w, canvas_h)
    OUTPUT_FILE.write_text(html, encoding="utf-8")
    print(f"Graph written to: {OUTPUT_FILE}")
    print("Open signal_graph_visual.html in your browser.")
