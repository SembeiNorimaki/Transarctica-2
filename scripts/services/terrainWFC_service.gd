extends Node
class_name TerrainWFCService

const DIRS = {
    0: Vector2i(0,-1),
    1: Vector2i(1,0),
    2: Vector2i(0,1),
    3: Vector2i(-1,0)
}

var tile_codes := {}
var adjacency := {}
var rng := RandomNumberGenerator.new()

var TILE_DATA := {
    Vector2i(0,0): [1,2,1,2],
    Vector2i(1,0): [1,3,1,2],
    Vector2i(2,0): [1,2,1,3],
    Vector2i(0,1): [2,2,3,2],
    Vector2i(1,1): [2,3,3,3],
    Vector2i(2,1): [2,2,3,2]
}

func _ready() -> void:
    setup(TILE_DATA)

func setup(codes: Dictionary) -> void:
    tile_codes = codes
    adjacency.clear()
    for a in tile_codes.keys():
        adjacency[a] = {0:[],1:[],2:[],3:[]}
    for a in tile_codes.keys():
        for b in tile_codes.keys():
            for d in DIRS.keys():
                var opp = (d + 2) % 4
                if tile_codes[a][d] == tile_codes[b][opp]:
                    adjacency[a][d].append(b)

func generate(w: int, h: int) -> Array:
    rng.randomize()
    var grid := []
    var poss := []
    var all := tile_codes.keys()
    for y in range(h):
        grid.append([])
        poss.append([])
        for x in range(w):
            grid[y].append(null)
            poss[y].append(all.duplicate())
    while true:
        var c := _lowest_entropy(poss, w, h)
        if c == null: break
        var x := c.x
        var y := c.y
        var opts = poss[y][x]
        if opts.is_empty():
            poss[y][x] = all.duplicate()
            continue
        var choice = opts[rng.randi_range(0, opts.size()-1)]
        grid[y][x] = choice
        poss[y][x] = [choice]
        _propagate(poss, w, h, x, y)
    return grid

func _lowest_entropy(poss: Array, w: int, h: int) -> Vector2i:
    var best = null
    var e := 999999
    for y in range(h):
        for x in range(w):
            var s = poss[y][x].size()
            if s > 1 and s < e:
                e = s
                best = Vector2i(x,y)
    return best

func _propagate(poss: Array, w: int, h: int, sx: int, sy: int) -> void:
    var stack := [Vector2i(sx,sy)]
    while stack.size() > 0:
        var c = stack.pop_back()
        var cx = c.x
        var cy = c.y
        var opts = poss[cy][cx]
        for d in DIRS.keys():
            var nx = cx + DIRS[d].x
            var ny = cy + DIRS[d].y
            if nx < 0 or ny < 0 or nx >= w or ny >= h: continue
            var allowed := []
            for t in opts:
                for n in adjacency[t][d]:
                    if n not in allowed:
                        allowed.append(n)
            var old = poss[ny][nx]
            var new := []
            for t in old:
                if t in allowed:
                    new.append(t)
            if new.size() < old.size():
                poss[ny][nx] = new
                stack.append(Vector2i(nx,ny))

func build_region_in_tilemap(tilemap: TileMap, layer: int, origin: Vector2i, w: int, h: int, source_id: int) -> void:
    var region := generate(w, h)
    for y in range(h):
        for x in range(w):
            var coord: Vector2i = region[y][x]
            if coord == null: continue
            tilemap.set_cell(layer, origin + Vector2i(x,y), source_id, coord)