extends Node
class_name CoverService

var edge_occupancy_service: EdgeOccupancyService

const COVER_VALUES := {
	Edge.CoverType.NONE: 0.0,
	Edge.CoverType.HALF: 0.5,
	Edge.CoverType.FULL: 1.0
}

# returns cover value for a tile against an enemy position
func get_cover_against(tile: Vector2i, enemy_tile: Vector2i) -> float:
	var dir = (enemy_tile - tile).sign()
	
	var edge := edge_occupancy_service.get_edge(tile, tile + dir)
	if edge == null:
		return COVER_VALUES[Edge.CoverType.NONE]

	return COVER_VALUES[edge.cover_type]

func get_cover_value(tile: Vector2i) -> float:
	var best := 0.0
	for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var edge = edge_occupancy_service.get_edge(tile, tile + dir)
		if edge == null:
			continue
		match edge.cover_type:
			Edge.CoverType.FULL:
				best = max(best, COVER_VALUES[Edge.CoverType.FULL])
			Edge.CoverType.HALF:
				best = max(best, COVER_VALUES[Edge.CoverType.HALF])
	return best
