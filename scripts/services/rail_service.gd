extends Node
class_name RailService

# Injected by NavigationScene
var rails_tilemap: TileMapLayer

const DIRS = {
	"N": Vector2i(0, -1),
	"E": Vector2i(1, 0),
	"S": Vector2i(0, 1),
	"W": Vector2i(-1, 0)
}


#var rail_graph := {}
#var rails := {} # tile -> rail_code (e.g. "NS", "EW", "NSe")
var edges = {} # tile -> Array[RailEdge]

func spawn_rail(tile: Vector2i, rail_name: String) -> void:
	print("Spawning rail %s at %s" % [rail_name, tile])

	# Place the simplest rail, atlascoords (0, 0)
	#rails_tilemap.set_cell(tile, 0, Vector2i(0, 0))

	# update internal graph
	#_add_to_graph(tile)
	_rebuild_edges_for_tile(tile, rail_name)

func _rebuild_edges_for_tile(tile: Vector2i, rail_name: String) -> void:
	edges[tile] = []
	var letters = rail_name.split("") # eg: ["N", "S"]

	if letters.size() == 2:
		var a = letters[0]
		var b = letters[1]
		edges[tile].append(RailEdge.new(a, b, 1))

	elif letters.size() == 3: # Junctions
		var a = letters[0]
		var b = letters[1]
		var c = letters[2]
		edges[tile].append(RailEdge.new(a, b, 1))
		edges[tile].append(RailEdge.new(a, c, 1))
		edges[tile].append(RailEdge.new(b, c, 1))

	elif letters.size() == 4:
		var a = letters[0]
		var b = letters[1]
		var c = letters[2]
		var d = letters[3]
		edges[tile].append(RailEdge.new(a, b, 1))
		edges[tile].append(RailEdge.new(c, d, 1))
		
		
# func _has_rail(tile: Vector2i) -> bool:
# 	return rail_graph.has(tile)

# func _add_to_graph(tile: Vector2i) -> void:
# 	rail_graph[tile] = []
