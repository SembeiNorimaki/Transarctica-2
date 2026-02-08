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


var rail_graph := {}
var rails := {} # tile -> rail_code (e.g. "NS", "EW", "NSe")
var edges = {} # tile -> Array[Edge]

func spawn_rail(tile: Vector2i, rail_name: String) -> void:
	print("Spawning rail %s at %s" % [rail_name, tile])

	# Place the simplest rail, atlascoords (0, 0)
	#rails_tilemap.set_cell(tile, 0, Vector2i(0, 0))

	# update internal graph
	_add_to_graph(tile)
	_rebuild_edges_for_tile(tile, rail_name)

func _rebuild_edges_for_tile(tile: Vector2i, rail_name: String) -> void:
	edges[tile] = []
	var letters = rail_name.split("") # eg: ["N", "S"]

	#Active connection is always the first two letters
	var active_a = letters[0]
	var active_b = letters[1]

	# Build active edges
	_add_edge(tile, active_a)
	_add_edge(tile, active_b)

	# If there is a junction, add it too
	if letters.size() == 3:
		var junction = letters[2]
		_add_edge(tile, junction)

func _add_edge(tile: Vector2i, dir_letter: String) -> void:
	var neighbor = tile + DIRS[dir_letter]
	var edge = Edge.new(tile, neighbor)
	edges[tile].append(edge)
		

func _has_rail(tile: Vector2i) -> bool:
	return rail_graph.has(tile)

func _add_to_graph(tile: Vector2i) -> void:
	rail_graph[tile] = []
