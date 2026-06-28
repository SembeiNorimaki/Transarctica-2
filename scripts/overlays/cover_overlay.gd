extends Node2D
class_name CoverOverlay

var grid_service: GridService

var covers = {}

const COVER_COLORS = {
    0.5: Color(0, 1, 0, 0.3),
    1.0: Color(0, 1, 0, 0.8),
}

func show_covers(covers_):
    covers = covers_
    queue_redraw()

func clear():
    covers.clear()
    queue_redraw()

func _draw():
    for tile in covers.keys():
        var cover_data = covers[tile]
        _draw_cover(tile, cover_data, Color(0, 1, 0, 0.3))
    

func _draw_cover(tile, cover_data, _color):
    print("Drawing cover for tile %s: %s" % [tile, cover_data])
    
    var world_pos = grid_service.tile_to_world(tile)
    var local_pos = world_pos
    var half_tile_size = grid_service.tile_half_size

    if cover_data.W > 0.0:
        draw_line(local_pos + Vector2(0, -half_tile_size.y + 6),
                  local_pos + Vector2(-half_tile_size.x + 12, 0), COVER_COLORS[cover_data.W], 3.0)
    if cover_data.E > 0.0:
        draw_line(local_pos + Vector2(0, half_tile_size.y - 6),
                  local_pos + Vector2(half_tile_size.x - 12, 0), COVER_COLORS[cover_data.E], 3.0)
    if cover_data.S > 0.0:
        draw_line(local_pos + Vector2(-half_tile_size.x + 12, 0),
                  local_pos + Vector2(0, half_tile_size.y - 6), COVER_COLORS[cover_data.S], 3.0)
    if cover_data.N > 0.0:
        draw_line(local_pos + Vector2(half_tile_size.x - 12, 0),
                  local_pos + Vector2(0, -half_tile_size.y + 6), COVER_COLORS[cover_data.N], 3.0)
