extends Node
class_name EdgeOccupancyService

var tile_size = Vector2i(32, 16)

var _blocked_edges := {}

func _ready() -> void:
	pass

#region Public API
func register(tile_a: Vector2i, tile_b: Vector2i) -> void:
	_blocked_edges[_edge_key(tile_a, tile_b)] = [tile_a, tile_b]

func unregister(tile_a: Vector2i, tile_b: Vector2i) -> void:
	_blocked_edges.erase(_edge_key(tile_a, tile_b))

func is_edge_blocked(tile_a: Vector2i, tile_b: Vector2i) -> bool:
	return _blocked_edges.has(_edge_key(tile_a, tile_b))

func get_blocked_edges() -> Dictionary:
	return _blocked_edges

func get_tiles(key: String):
	return _blocked_edges[key]

func clear() -> void:
	_blocked_edges.clear()
#endregion

func _edge_key(a: Vector2i, b: Vector2i) -> String:
	# Sort to ensure A→B and B→A are identical
	if a < b:
		return str(a) + "_" + str(b)
	return str(b) + "_" + str(a)
