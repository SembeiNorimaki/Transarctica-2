extends Node2D
class_name PathOverlay

var grid_service: GridService
var path_tiles: Array[Vector2i] = []

func _ready():
    set_process(false)

func redraw():
    _draw()
    
func show_path(path: Array[Vector2i]):
    print("Showing path:", path)
    path_tiles = path
    _draw()

func clear_path():
    #path_tiles.clear()
    _draw()

func _draw():
    for tile in path_tiles:
        var world_pos = grid_service.tile_to_world(tile)
        var local_pos = grid_service.world_to_screen(world_pos)
        print("Drawing path at:", local_pos)
        draw_circle(Vector2i(100,100),50, Color.BLACK)
        #draw_circle(local_pos, 50, Color.BLACK)
