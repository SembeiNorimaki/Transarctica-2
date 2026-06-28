extends Node2D
class_name ReachableTilesOverlay

var grid_service: GridService

func setup(deps: Dictionary) -> void:
    grid_service = deps["grid_service"]

var tiles: Array[Vector2i] = []
var came_from: Dictionary = {} # tile -> prev tile

func show_tiles(tiles_, came_from_):
    tiles = tiles_
    came_from = came_from_
    queue_redraw()

func clear():
    tiles.clear()
    queue_redraw()

func _draw():
    for tile in tiles:
        _highlight_tile(tile, Color(0, 1, 0, 0.3))
    
    _draw_paths(Color(1, 0, 0, 0.8))

func _highlight_tile(tile, color_):
    var world_pos = grid_service.tile_to_world(tile)
    var half_tile_size = grid_service.tile_half_size
    
    var points = PackedVector2Array([
            world_pos + Vector2(0, -half_tile_size.y + 2), # Top
            world_pos + Vector2(half_tile_size.x - 2, 0), # Right
            world_pos + Vector2(0, half_tile_size.y - 2), # Bottom
            world_pos + Vector2(-half_tile_size.x + 2, 0) # Left
    ])
    draw_colored_polygon(points, color_)

func _draw_paths(color_: Color, width: float = 2.0):
    for tile in came_from:
        var parent: Vector2i = came_from[tile]
        var from_pos = grid_service.tile_to_world(tile)
        var to_pos = grid_service.tile_to_world(parent)
        draw_line(from_pos, to_pos, color_, width)
