extends Node2D
class_name DefensivenessOverlay

var grid_service: GridService
var danger_map = {}

func update():
    queue_redraw()

func _draw():
    for tile in danger_map.keys():
        var score = danger_map[tile]
        var world_pos = grid_service.tile_to_world(tile)
        var local_pos = world_pos
        var half_tile_size = grid_service.tile_half_size

        var color_ = Color(0, 1, 0, 0.3) # good

        if score > 10:
            color_ = Color(1, 1, 0, 0.5) # better
            
        
        #draw_string(font, local_pos + Vector2(4, 24), str(score), color_)

        var points = PackedVector2Array([
            local_pos + Vector2(0, -half_tile_size.y), # Top
            local_pos + Vector2(half_tile_size.x, 0), # Right
            local_pos + Vector2(0, half_tile_size.y), # Bottom
            local_pos + Vector2(-half_tile_size.x, 0) # Left
        ])
        draw_colored_polygon(points, color_)
