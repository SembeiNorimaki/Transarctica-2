extends Node
class_name LOSService

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var edge_occupancy_service: EdgeOccupancyService
var los_overlay: LOSOverlay

# computes the bresenham line between two tiles with no diagonals
func bresenham_line(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
    #print("Bresenham Line between %s and %s" % [start, end])
    var tiles: Array[Vector2i] = []

    var x0 = start.x
    var y0 = start.y
    var x1 = end.x
    var y1 = end.y

    var dx = x1 - x0
    var dy = y1 - y0

    var step_x = 1 if dx > 0 else -1
    var step_y = 1 if dy > 0 else -1

    # Avoid division by zero
    var t_delta_x = INF if dx == 0 else abs(1.0 / dx)
    var t_delta_y = INF if dy == 0 else abs(1.0 / dy)

    # Distance to first vertical/horizontal boundary
    var t_max_x = t_delta_x * 0.5
    var t_max_y = t_delta_y * 0.5

    var x = x0
    var y = y0

    tiles.append(Vector2i(x, y))

    while x != x1 or y != y1:
        if t_max_x < t_max_y:
            t_max_x += t_delta_x
            x += step_x
        else:
            t_max_y += t_delta_y
            y += step_y

        tiles.append(Vector2i(x, y))

    los_overlay.draw_debug_tiles(tiles)
    return tiles

# computes the bresenham line between two tiles with diagonals
func bresenham_line_diagonals(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
    #print("Bresenham Line between %s and %s" % [start, end])
    var tiles: Array[Vector2i] = []
    var x0 = start.x
    var y0 = start.y
    var x1 = end.x
    var y1 = end.y
    
    var dx = abs(x1 - x0)
    var dy = abs(y1 - y0)
    var sx = 1 if x0 <= x1 else -1
    var sy = 1 if y0 <= y1 else -1
    var err = dx - dy
    
    var idx = 0
    while idx < 100:
        #print(Vector2i(x0, y0))
        tiles.append(Vector2i(x0, y0))
        if x0 == x1 and y0 == y1:
            break
        var e2 = err * 2
        if e2 > -dy:
            err -= dy
            x0 += sx
        if e2 < dx:
            err += dx
            y0 += sy
        idx += 1
    
    los_overlay.draw_debug_tiles(tiles)
    return tiles

func has_los(start: Vector2i, end: Vector2i) -> bool:
    #print("Calculating LOS between %s and %s" % [start, end])
    var tiles = bresenham_line(start, end)

    for i in range(0, tiles.size() - 1):
        var tile1 = tiles[i]
        var tile2 = tiles[i + 1]
        var is_blocked = edge_occupancy_service.is_edge_view_blocked(tile1, tile2)
        if is_blocked:
            #print("LOS Blocked")
            los_overlay.draw_los_line(start, end, Color.RED)
            return false
        # If the tile is the target, LOS is valid
        #if tile == end:
        #    return true
        
        # If any tile in between is statically blocked, LOS fails
        #if tile_occupancy_service.is_occupied_static(tile):
        #    return false
    los_overlay.draw_los_line(start, end, Color.GREEN)
    return true


# Given all tiles in a cone and an origin, compute those ones that are visible, so they have LOS
func filter_visible_tiles(origin: Vector2i, cone_tiles: Array[Vector2i]) -> Array[Vector2i]:
    var visible_tiles: Array[Vector2i] = []
    for tile in cone_tiles:
        if has_los(origin, tile):
            visible_tiles.append(tile)
    return visible_tiles
