extends Node2D

var grid_service: GridService
var tile_occupancy_service: TileOccupancyService
var edge_occupancy_service: EdgeOccupancyService

const EDGE_COLORS := {
	Edge.EdgeType.NORMAL: Color(1, 1, 1, 0.4), # white
	Edge.EdgeType.WALL: Color(1, 0, 0, 0.8), # red
	Edge.EdgeType.FENCE: Color(0, 1, 0, 0.8), # green
	Edge.EdgeType.WINDOW: Color(0, 0.5, 1, 0.8), # blue
	Edge.EdgeType.DOOR: Color(1, 0.6, 0, 0.8) # orange
}

func _ready():
	set_process(false)

func redraw():
	#print("Redrawing walls overlay")
	_draw()
	queue_redraw()

func _draw():
	if grid_service == null or tile_occupancy_service == null:
		return

	_draw_tile_walls()
	_draw_edge_walls()

func _draw_tile_walls():
	# draw tile-based walls
	for tile in tile_occupancy_service.get_occupied_tiles():
		var walls = tile_occupancy_service.get_walls(tile)
		if walls.is_empty():
			continue
		
		var world_pos = grid_service.tile_to_world(tile)
		var screen_pos = world_pos # grid_service.world_to_screen(world_pos)
		
		var half_w = grid_service.tile_half_width
		var half_h = grid_service.tile_half_height
		
		var points = PackedVector2Array([
			screen_pos + Vector2(0, -half_h), # Top
			screen_pos + Vector2(half_w, 0), # Right
			screen_pos + Vector2(0, half_h), # Bottom
			screen_pos + Vector2(-half_w, 0) # Left
		])
		draw_colored_polygon(points, Color(0.0, 1.0, 1.0, 0.3))

func _draw_edge_walls():
	# draw edge-based walls
	for key in edge_occupancy_service.get_all_edges().keys():
		var edge: Edge = edge_occupancy_service.get_all_edges()[key]

		var pts = _edge_to_screen_points(edge)
		var color = EDGE_COLORS.get(edge.edge_type, Color(1, 1, 1, 0.5))

		draw_line(pts[0], pts[1], color, 3)

func _edge_to_screen_points(edge: Edge) -> Array[Vector2i]:
	var a_world = grid_service.tile_to_world(edge.from_tile)
	var b_world = grid_service.tile_to_world(edge.to_tile)
	
	var a_screen = a_world # grid_service.world_to_screen(a_world)
	var b_screen = b_world # grid_service.world_to_screen(b_world)
	
	# Offset inward so the line sits visually between tiles
	var mid = (a_screen + b_screen) * 0.5
	var dir = (b_screen - a_screen).normalized()
	
	# Perpendicular for thickness
	var perp = Vector2(-dir.y, dir.x)

	var p1 = mid + perp * 6
	var p2 = mid - perp * 6

	return [p1, p2]
