extends Node2D
class_name LOSOverlay

var grid_service: GridService

var _tiles_to_draw = []
var _lines_to_draw = []

func redraw() -> void:
	_draw()

func _draw():
	if grid_service == null:
		return
	for tile in _tiles_to_draw:
		highlight_tile(tile)
	for line_ in _lines_to_draw:
		var pos1 = grid_service.tile_to_world(line_[0])
		var pos2 = grid_service.tile_to_world(line_[1])
		draw_line(pos1, pos2, Color.BLACK)

func draw_debug_line():
	pass

func highlight_tile(tile):
	var world_pos = grid_service.tile_to_world(tile)
	var local_pos = world_pos
	var half_tile_size = grid_service.tile_half_size
	
	var points = PackedVector2Array([
			local_pos + Vector2(0, -half_tile_size.y), # Top
			local_pos + Vector2(half_tile_size.x, 0), # Right
			local_pos + Vector2(0, half_tile_size.y), # Bottom
			local_pos + Vector2(-half_tile_size.x, 0) # Left
	])
	#print("HTS", points)
	draw_colored_polygon(points, Color.BROWN)

func draw_debug_tiles(tiles: Array):
	_tiles_to_draw = []
	#print("Draw debug tiles %s" % [tiles])
	for i in range(tiles.size()):
		pass
		#_tiles_to_draw.append(tiles[i])
		##print("Tiles %s and  %s" % [tiles[i], tiles[i+1]])
	_lines_to_draw.append([tiles[0], tiles[tiles.size() - 1]])
	queue_redraw()
