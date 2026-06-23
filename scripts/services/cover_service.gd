extends Node
class_name CoverService

var edge_occupancy_service: EdgeOccupancyService
var cover_overlay: CoverOverlay

# precomputed covers for each tile in the map
# cover_map[tile] = {"N": val, "S": val, "E": val, "W": val}
var cover_map := {}

const COVER_VALUES := {
	Edge.CoverType.NONE: 0.0,
	Edge.CoverType.HALF: 0.5,
	Edge.CoverType.FULL: 1.0
}

func build_cover_map(all_tiles: Array):
	print("Precomputing covers...")
	cover_map.clear()

	for tile in all_tiles:
		var entry = {
			"N": _cover_in_direction(tile, Vector2i.UP),
			"S": _cover_in_direction(tile, Vector2i.DOWN),
			"W": _cover_in_direction(tile, Vector2i.LEFT),
			"E": _cover_in_direction(tile, Vector2i.RIGHT)
		}
		# Only store tiles that have ANY cover
		if entry.N > 0.0 or entry.S > 0.0 or entry.W > 0.0 or entry.E > 0.0:
			print("Found cover in tile %s" % tile)
			cover_map[tile] = entry
	cover_overlay.show_covers(cover_map)
		
func _cover_in_direction(tile: Vector2i, dir: Vector2i) -> float:
	var edge = edge_occupancy_service.get_edge(tile, tile + dir)
	if edge == null:
		return COVER_VALUES[Edge.CoverType.NONE]
	return COVER_VALUES[edge.cover_type]


# returns cover value for a tile against an enemy position
func get_cover_against(tile: Vector2i, enemy_tile: Vector2i) -> float:
	var entry = cover_map.get(tile)
	if entry == null:
		# tile not in dict, meaning it has no cover
		return COVER_VALUES[Edge.CoverType.NONE]

	var delta = enemy_tile - tile
	var angle = rad_to_deg(atan2(delta.y, delta.x))
	angle = fposmod(angle + 360.0, 360.0)

	# North arc: 315-45
	if angle >= 315.0 or angle < 45.0:
		return cover_map[tile].E
	# East arc: 45-135
	elif angle >= 45.0 and angle < 135.0:
		return cover_map[tile].S
	# South arc: 135-225
	elif angle >= 135.0 and angle < 225.0:
		return cover_map[tile].W
	# West arc: 225-315
	elif angle >= 225.0 and angle < 315.0:
		return cover_map[tile].N

	return COVER_VALUES[Edge.CoverType.NONE]
	

func get_cover_value(tile: Vector2i) -> float:
	var entry = cover_map.get(tile)
	if entry == null:
		# tile not in dict, meaning it has no cover
		return COVER_VALUES[Edge.CoverType.NONE]
	return max(entry.N, entry.S, entry.E, entry.W)
