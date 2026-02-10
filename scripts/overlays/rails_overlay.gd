extends Node2D
class_name RailsOverlay

var grid_service: GridService
var rail_service: RailService

func _ready():
	set_process(false)

func update():
	print("Updating rails overlay")
	_draw()
	queue_redraw()

func _draw():
	print("Drawing rails overlay")
	for edges in rail_service.edges.values():
		for edge in edges:
			#print("%s -> %s" % [edge.from_tile, edge.to_tile])
			draw_line(
				grid_service.tile_to_world(edge.from_tile),
				grid_service.tile_to_world(edge.to_tile),
				Color.RED, 2)
		
			draw_circle(grid_service.tile_to_world(edge.from_tile), 6, Color.RED)
			#draw_circle(grid_service.tile_to_world(edge.to_tile), 4, Color.GREEN)
