extends Node2D
class_name PathOverlay

var grid_service: GridService
var path_tiles: Array[Vector2i] = []
var path_cost: Array[float] = []

func _ready():
    set_process(false)

func redraw():
    queue_redraw()
    
func show_path(path_: Array[Vector2i], path_cost_: Array[float]):
    path_tiles = path_
    path_cost = path_cost_
    queue_redraw()

func show_path_debug(unit, path_: Array[Vector2i]):
    show_path(path_.duplicate(), [])

func update(unit, prev_tile, new_tile):
    queue_redraw()

func clear_path():
    path_tiles.clear()
    queue_redraw()

func _draw():
    if path_tiles.is_empty():
        return
    var prev_tile = path_tiles[0]
    var prev_cost = path_cost[0] if not path_cost.is_empty() else 0.0
    var prev_world_pos = grid_service.tile_to_world(prev_tile)
    var prev_local_pos = prev_world_pos
    var accum_cost = 0
    #draw_circle(prev_local_pos, 5, Color.GREEN)
    for i in range(1, path_tiles.size()):
        var tile = path_tiles[i]
        var world_pos = grid_service.tile_to_world(tile)
        var local_pos = world_pos
        var cost = path_cost[i] if i < path_cost.size() else 0.0
        accum_cost += cost
        #print("Drawing path at:", local_pos)
        draw_circle(local_pos, 2, Color.BLACK)
        if accum_cost < 5:
            draw_line(prev_local_pos, local_pos, Color.GREEN, 3)
        elif accum_cost < 8:
            draw_line(prev_local_pos, local_pos, Color.YELLOW, 3)
        else:
            draw_line(prev_local_pos, local_pos, Color.RED, 3)
        draw_circle(local_pos, 2, Color.BLACK)
        
        prev_local_pos = local_pos
