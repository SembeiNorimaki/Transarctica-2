extends Node2D

var grid_service: GridService
var tile_occupancy_service: TileOccupancyService

func _ready():
    pass
    #set_process(false)
    #update()

func redraw():
    _draw()
    queue_redraw()

func update(unit, new_tile):
    print("Unit overlay update, new tile %s" % new_tile)
    _draw()
    queue_redraw()

func _draw():
    print("Unit overlay draw")
    if grid_service == null or tile_occupancy_service == null:
        return
    for tile in tile_occupancy_service.get_occupied_tiles():
        var units = tile_occupancy_service.get_units(tile)
        if units.is_empty():
            continue
        
        var world_pos = grid_service.tile_to_world(tile)
        var local_pos = world_pos
        #print(tile, world_pos, local_pos)
        var half_width = grid_service.tile_size.x / 2.0
        var half_height = grid_service.tile_size.y / 2.0
        
        var points = PackedVector2Array([
            local_pos + Vector2(0, -half_height), # Top
            local_pos + Vector2(half_width, 0), # Right
            local_pos + Vector2(0, half_height), # Bottom
            local_pos + Vector2(-half_width, 0) # Left
        ])
        draw_colored_polygon(points, Color(0.0, 1.0, 0.0, 0.3))
