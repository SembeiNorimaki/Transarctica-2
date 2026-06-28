extends Node2D
class_name FOVOverlay

# Dependencies
var grid_service: GridService

var _tiles_to_draw_red = []
var _tiles_to_draw_green = []
var _tiles_to_draw_blue = []


func redraw() -> void:
    _draw()

func _draw():
    for tile in _tiles_to_draw_red:
        _highlight_tile(tile, Color(1, 0, 0, 0.2))
    for tile in _tiles_to_draw_green:
        _highlight_tile(tile, Color(0, 1, 0, 0.2))
    for tile in _tiles_to_draw_blue:
        _highlight_tile(tile, Color(0, 0, 1, 0.2))
    queue_redraw()
        
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
