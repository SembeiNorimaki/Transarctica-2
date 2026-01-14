extends Node2D

var grid_service: GridService
var tile_occupancy_service: TileOccupancyService

func redraw() -> void:
    print("Redrawing walls overlay")
    _draw()

func _draw():
    if grid_service == null or tile_occupancy_service == null:
        return
    for tile in tile_occupancy_service.get_occupied_tiles():
        var buildings = tile_occupancy_service.get_buildings(tile)
        if buildings.is_empty():
            continue
        #print("Drawing building overlay at location %s" % tile)
        var world_pos = grid_service.tile_to_world(tile)
        var local_pos = world_pos
        #var rect = Rect2(world_pos, Vector2(grid_service.tile_size.x, grid_service.tile_size.y))
        #draw_rect(rect, Color(1, 0, 0, 0.5), true)

        var half_width = grid_service.tile_size.x / 2.0
        var half_height = grid_service.tile_size.y / 2.0
        
        var points = PackedVector2Array([
            local_pos + Vector2(0, -half_height), # Top
            local_pos + Vector2(half_width, 0), # Right
            local_pos + Vector2(0, half_height), # Bottom
            local_pos + Vector2(-half_width, 0) # Left
        ])
        draw_colored_polygon(points, Color(1.0, 0.0, 0.0, 0.3))