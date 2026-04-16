extends Node
class_name EdgeOccupancyService

var tile_size = Vector2i(32, 16)

# Dictionary <String, Edge>
var _edges := {}

func _ready() -> void:
	pass

#region Public API
func register(tile_a: Vector2i, tile_b: Vector2i, edge_type_: int = Edge.EdgeType.NORMAL) -> void:
	var key := _edge_key(tile_a, tile_b)
	var edge = EdgeFactory.create_edge(tile_a, tile_b, edge_type_)
	_edges[key] = edge

func unregister(tile_a: Vector2i, tile_b: Vector2i) -> void:
	_edges.erase(_edge_key(tile_a, tile_b))

func is_edge_walk_blocked(tile_a: Vector2i, tile_b: Vector2i) -> bool:
	var edge_key = _edge_key(tile_a, tile_b)
	return _edges.has(edge_key) and _edges[edge_key].blocks_movement

func is_edge_view_blocked(tile_a: Vector2i, tile_b: Vector2i) -> bool:
	var edge_key = _edge_key(tile_a, tile_b)
	return _edges.has(edge_key) and _edges[edge_key].blocks_vision


func get_edge(tile_a: Vector2i, tile_b: Vector2i) -> Edge:
	return _edges.get(_edge_key(tile_a, tile_b), null)

func get_all_edges() -> Dictionary:
	return _edges


func get_tiles(edge_str: String) -> Array[Vector2i]:
	return _edges.get(edge_str).get_tiles()
	
func clear() -> void:
	_edges.clear()
#endregion

func _edge_key(a: Vector2i, b: Vector2i) -> String:
	# Sort to ensure A→B and B→A are identical
	if a < b:
		return str(a) + "_" + str(b)
	return str(b) + "_" + str(a)
