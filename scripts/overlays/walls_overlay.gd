extends Node2D

var grid_service: GridService
var tile_occupancy_service: TileOccupancyService
var edge_occupancy_service: EdgeOccupancyService

func _ready():
	set_process(false)

func redraw():
	print("Redrawing walls overlay")
	_draw()
	queue_redraw()

func _draw():
	if grid_service == null or tile_occupancy_service == null:
		return
	for tile in tile_occupancy_service.get_occupied_tiles():
		var walls = tile_occupancy_service.get_walls(tile)
		if walls.is_empty():
			continue
		print("Drawing wall overlay at location %s" % tile)
		var world_pos = grid_service.tile_to_world(tile)
		var local_pos = grid_service.world_to_screen(world_pos)
		
		var half_width = grid_service.tile_size.x / 2.0
		var half_height = grid_service.tile_size.y / 2.0
		
		var points = PackedVector2Array([
			local_pos + Vector2(0, -half_height), # Top
			local_pos + Vector2(half_width, 0), # Right
			local_pos + Vector2(0, half_height), # Bottom
			local_pos + Vector2(-half_width, 0) # Left
		])
		draw_colored_polygon(points, Color(0.0, 1.0, 1.0, 0.3))

	for edge_str in edge_occupancy_service.get_blocked_edges():
		var tiles = edge_occupancy_service.get_tiles(edge_str)
		print("Drawing wall edge overlay at location %s" % tiles[0])
		var world_pos = grid_service.tile_to_world(tiles[0])
		var local_pos = world_pos

		var half_width = grid_service.tile_size.x / 2.0
		var half_height = grid_service.tile_size.y / 2.0

		var points = PackedVector2Array([
			local_pos + Vector2(-2, -half_height - 4),
			local_pos + Vector2(2, -half_height + 4),
			local_pos + Vector2(-half_width + 2, 4),
			local_pos + Vector2(-half_width - 2, -4)
			# local_pos + Vector2(0, -half_height), # Top
			# local_pos + Vector2(half_width, 0), # Right
			# local_pos + Vector2(0, half_height), # Bottom
			# local_pos + Vector2(-half_width, 0) # Left
			
		])
		draw_colored_polygon(points, Color(0.0, 0.0, 1.0, 0.5))
