extends Node2D
class_name MouseHoverOverlay

var grid_service: GridService
var tile_size := Vector2(32, 16)
var current_tile := Vector2i(-1, -1)

func _process(delta: float) -> void:
    var mouse_pos = get_local_mouse_position()
    var tile = grid_service.world_to_tile(mouse_pos)
    if tile != current_tile:
        current_tile = tile
        #update()

func update():
    _draw()
    queue_redraw()

func _draw():
    if current_tile != Vector2i(-1, -1):
        var world_pos = grid_service.tile_to_world(current_tile)
        var local_pos = world_pos
        var half_width = tile_size.x / 2.0
        var half_height = tile_size.y / 2.0
        var points = PackedVector2Array([
            local_pos + Vector2(0, -half_height), # Top
            local_pos + Vector2(half_width, 0), # Right
            local_pos + Vector2(0, half_height), # Bottom
            local_pos + Vector2(-half_width, 0) # Left
        ])
        draw_colored_polygon(points, Color(0.0, 1.0, 0.0, 0.3))
