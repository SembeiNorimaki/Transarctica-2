extends Node2D
class_name LOSOverlay

var grid_service: GridService

func redraw() -> void:
    _draw()

func _draw():
    if grid_service == null:
        return

# func debug_draw_line(start: Vector2i, end: Vector2i, color := Color.red):
#     var tiles = bresenham_line(start, end)
#     for tile in tiles:
#         debug_overlay.draw_tile(tile, color)
