class_name Edge
extends Resource

var from_tile: Vector2i
var to_tile: Vector2i
var cost: float
var blocks_movement: bool = false
var blocks_vision: bool = false
var blocks_fire: bool = false

enum CoverType {NONE, HALF, FULL}
var cover_type: int = CoverType.NONE
enum EdgeType {NORMAL, WALL, FENCE, WINDOW, DOOR}
var edge_type: int = EdgeType.NORMAL

var is_destructible: bool = false
var hp: int = 100

func _init(from_tile_: Vector2i, to_tile_: Vector2i, edge_type_: int = EdgeType.NORMAL):
    from_tile = from_tile_
    to_tile = to_tile_
    edge_type = edge_type_

func get_tiles() -> Array[Vector2i]:
    return [from_tile, to_tile]