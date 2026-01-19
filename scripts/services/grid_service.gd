extends Node

class_name GridService

# Injected by CombatScene
var tile_size: Vector2i
var map_origin: Vector2
var map_size: Vector2i
var camera_transform: Transform2D


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

func _ready() -> void:
    pass


func test():
    pass
    # print("GridService tests")
    # print(tile_to_world(Vector2i(0, 0)))
    # print(tile_to_world(Vector2i(1, 0)))
    # print(tile_to_world(Vector2i(0, 1)))
    # print(tile_to_world(Vector2i(1, 1)))

    # print(world_to_tile(Vector2(0, 0)))
    # print(world_to_tile(Vector2(16, 8)))
    # print(world_to_tile(Vector2(32, 16)))
    # print(world_to_tile(Vector2(0, 16)))
    # print(world_to_tile(Vector2(16, 24)))

func tile_to_world(tile: Vector2i) -> Vector2:
    var world_x = (tile.x - tile.y) * tile_size.x / 2
    var world_y = (tile.x + tile.y) * tile_size.y / 2
    return map_origin + Vector2(world_x, world_y)
    
func world_to_tile(world_pos: Vector2) -> Vector2i:
    var p = world_pos - map_origin
    var tile_x = (p.x / (tile_size.x / 2) + p.y / (tile_size.y / 2)) / 2
    var tile_y = (p.y / (tile_size.y / 2) - p.x / (tile_size.x / 2)) / 2
    return Vector2i(floor(tile_x), floor(tile_y))

func screen_to_world(screen_pos: Vector2) -> Vector2:
    return (-camera_transform.origin + screen_pos) / (camera_transform.get_scale())

func world_to_screen(world_pos: Vector2) -> Vector2:
    return world_pos - camera_transform.origin

func screen_to_tile(screen_pos: Vector2) -> Vector2i:
    return world_to_tile(screen_to_world(screen_pos))

func tile_to_screen(tile_pos: Vector2i) -> Vector2:
    return world_to_screen(tile_to_world(tile_pos))

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
    # Normalize to -1, 0, or 1
    var dx = clamp(delta.x, -1, 1)
    var dy = clamp(delta.y, -1, 1)
    var key := Vector2i(dx, dy)

    var map := {
        Vector2i(-1, -1): "NW",
        Vector2i(0, -1): "N",
        Vector2i(1, -1): "NE",
        Vector2i(-1, 0): "W",
        Vector2i(1, 0): "E",
        Vector2i(-1, 1): "SW",
        Vector2i(0, 1): "S",
        Vector2i(1, 1): "SE"
    }
    var result = map.get(key, "")
    print("From tile: %s, to tile: %s, orientation: %s" % [from_tile, to_tile, result])

    return result

func get_tiles_in_vision_cone(origin: Vector2i, orientation: String, view_angle: float, view_range: int) -> Array:
    var result = []
    var forward = ORIENTATION_VECTORS[orientation]
    var half_angle = deg_to_rad(view_angle / 2.0)

    # Iterate all tiles in a square around the unit
    for x in range(origin.x - view_range, origin.x + view_range + 1):
        for y in range(origin.y - view_range, origin.y + view_range + 1):
            var tile := Vector2i(x, y)
            # Skip origin
            if tile == origin:
                continue
            # Range check
            var delta = tile - origin
            if delta.length() > view_range:
                continue
            
            # Angle check
            var dir = delta.normalized()
            var angle = forward.angle_to(dir)
            if abs(angle) <= half_angle:
                result.append(tile)
            
            
    return result
            

func update_camera_transform(t: Transform2D) -> void:
    #print("Setting camera transfor to %s" % t)
    camera_transform = t
