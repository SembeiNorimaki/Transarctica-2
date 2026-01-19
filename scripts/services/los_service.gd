extends Node
class_name LOSService

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService

func bresenham_line(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
    var line = []
    var dx = end.x - start.x
    var dy = end.y - start.y
    var sx = 1 if dx > 0 else -1
    var sy = 1 if dy > 0 else -1
    var err = dx - dy
    
    while true:
        line.append(Vector2i(start.x, start.y))
        if start == end:
            return line
        var e2 = err * 2
        if e2 > -dy:
            err -= dy
            start.x += sx
        if e2 < dx:
            err += dx
            start.y += sy
    return line

func has_los(start: Vector2i, end: Vector2i) -> bool:
    var tiles = bresenham_line(start, end)

    for i in range(1, tiles.size()):
        var tile = tiles[i]

        # If the tile is the target, LOS is valid
        if tile == end:
            return true
        
        # If any tile in between is statically blocked, LOS fails
        if tile_occupancy_service.is_occupied_static(tile):
            return false
    return true
