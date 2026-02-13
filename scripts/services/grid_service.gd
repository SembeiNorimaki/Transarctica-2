extends Node
class_name GridService

# Injected by CombatScene
var tile_size: Vector2i
var tile_half_size: Vector2i
var map_origin: Vector2 # is basically half the tile_size
var map_size: Vector2i

var camera_controller: CameraController

var ORIENTATION_VECTORS := {
    "N": Vector2(0, -1),
    "NE": Vector2(1, -1).normalized(),
    "E": Vector2(1, 0),
    "SE": Vector2(1, 1).normalized(),
    "S": Vector2(0, 1),
    "SW": Vector2(-1, 1).normalized(),
    "W": Vector2(-1, 0),
    "NW": Vector2(-1, -1).normalized()
}

var DELTA_TO_ORI = {
    Vector2i(1, 0): "E",
    Vector2i(-1, 0): "W",
    Vector2i(0, 1): "S",
    Vector2i(0, -1): "N",
    Vector2i(1, 1): "SE",
    Vector2i(-1, 1): "SW",
    Vector2i(1, -1): "NE",
    Vector2i(-1, -1): "NW"
}

func set_tile_size(tile_size_: Vector2i):
    tile_size = tile_size_
    tile_half_size = Vector2i(tile_size_.x / 2, tile_size_.y / 2)
    map_origin = tile_half_size

func test():
    pass
    #print("GridService tests")
    # #print(tile_to_world(Vector2i(0, 0)))
    # #print(tile_to_world(Vector2i(1, 0)))
    # #print(tile_to_world(Vector2i(0, 1)))
    # #print(tile_to_world(Vector2i(1, 1)))

    #print(world_to_tile(Vector2(16, 1)))
    #print(world_to_tile(Vector2(16, 8)))
    #print(world_to_tile(Vector2(16, 14)))
    #print(world_to_tile(Vector2(3, 8)))
    #print(world_to_tile(Vector2(29, 8)))
    #print(world_to_tile(Vector2(9, 4)))
    #print(world_to_tile(Vector2(22, 4)))
    #print(world_to_tile(Vector2(8, 11)))
    #print(world_to_tile(Vector2(22, 11)))


#this doesn't use map_origin. Useful for relative positions of tiles
func tile_delta_to_world_delta(delta_tile: Vector2i) -> Vector2:
    return Vector2(
        (delta_tile.x - delta_tile.y) * tile_half_size.x,
        (delta_tile.x + delta_tile.y) * tile_half_size.y
    )

# Tile(0,0) -> World(16,8) 
func tile_to_world(tile: Vector2) -> Vector2:
    return map_origin + Vector2(
        (tile.x - tile.y) * tile_half_size.x,
        (tile.x + tile.y) * tile_half_size.y
    )

func world_to_tile(world_pos: Vector2) -> Vector2i:
    var p = world_pos - map_origin
    var tile_x = (p.x / tile_size.x) + (p.y / tile_size.y)
    var tile_y = (p.y / tile_size.y) - (p.x / tile_size.x)
    return Vector2i(round(tile_x), round(tile_y))


# func screen_to_world(screen_pos: Vector2) -> Vector2:
#     return screen_pos / camera_controller.zoom # + camera_controller.offset

# func world_to_screen(world_pos: Vector2) -> Vector2:
#     #return (world_pos - camera_controller.offset) * camera_controller.zoom
#     return world_pos * camera_controller.zoom

# func screen_to_tile(screen_pos: Vector2) -> Vector2i:
#     var world_pos = screen_to_world(screen_pos)
#     var tile_pos = world_to_tile(world_pos)
#     #print("Screen pos: %s, world pos: %s, tile pos: %s" % [screen_pos, world_pos, tile_pos])
#     return tile_pos

# func tile_to_screen(tile_pos: Vector2i) -> Vector2:
#     return world_to_screen(tile_to_world(tile_pos))

func get_neighbors(tile: Vector2i) -> Array[Vector2i]:
    var neighbors: Array[Vector2i] = []
    for x in [-1, 0, 1]:
        for y in [-1, 0, 1]:
            if x == 0 and y == 0:
                continue
            neighbors.append(tile + Vector2i(x, y))

        neighbors = [tile + Vector2i(1, 0), tile + Vector2i(-1, 0), tile + Vector2i(0, 1), tile + Vector2i(0, -1)]
    return neighbors

func get_orientation(from_tile: Vector2i, to_tile: Vector2i) -> String:
    var delta = to_tile - from_tile
    var dx = delta.x
    var dy = delta.y
    # Boundaries between cardinal and diagonal directions
    var k = 0.4142 # tan(22.5°)
    var ori := ""
    if abs(dx) > abs(dy):
        # Horizontal dominant
        if dx > 0:
            if dy > dx * k:
                ori = "SE"
            elif dy < -dx * k:
                ori = "NE"
            else:
                ori = "E"
        else:
            if dy > -dx * k:
                ori = "SW"
            elif dy < dx * k:
                ori = "NW"
            else:
                ori = "W"
    else:
        # Vertical dominant
        if dy > 0:
            if dx > dy * k:
                ori = "SE"
            elif dx < -dy * k:
                ori = "SW"
            else:
                ori = "S"
        else:
            if dx > -dy * k:
                ori = "NE"
            elif dx < dy * k:
                ori = "NW"
            else:
                ori = "N"

    
    #print("From tile: %s, to tile: %s, orientation: %s" % [from_tile, to_tile, ori])

    return ori

func get_tiles_in_vision_cone(origin: Vector2i, orientation: String, view_angle: float, view_range: int) -> Array[Vector2i]:
    #print("get tiles in vision cone %s %s %s %s %s" % [origin, orientation, view_angle, view_range, map_size])
    var result: Array[Vector2i] = []
    var forward = ORIENTATION_VECTORS[orientation]
    var half_angle = deg_to_rad(view_angle / 2.0)

    # Iterate all tiles in a square around the unit
    for x in range(max(0, origin.x - view_range), min(map_size.x, origin.x + view_range + 1)):
        for y in range(max(0, origin.y - view_range), min(map_size.y, origin.y + view_range + 1)):
            var tile := Vector2i(x, y)
            # Skip origin
            if tile == origin:
                continue
            # Range check
            var delta = tile - origin
            if delta.length() > view_range:
                continue
            
            
            # Angle check
            var dir = Vector2(delta).normalized()
            var angle = forward.angle_to(dir)
            if abs(angle) <= half_angle + 0.01:
                result.append(tile)
            
            
    return result

func is_inside_map(tile: Vector2i) -> bool:
    return tile.x >= 0 and tile.x < map_size.x and tile.y >= 0 and tile.y < map_size.y
