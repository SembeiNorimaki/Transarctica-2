extends Node
class_name RoadService

# Injected by CombatScene

var road_tiles := {}


signal road_spawned(road)

func _ready() -> void:
	pass

func spawn_road(tile_pos) -> void:
	# #print("Spawning a road at %s" % tile_pos)
	# Register road
	if tile_pos not in road_tiles:
		road_tiles[tile_pos] = true

	emit_signal("road_spawned", "road")

func get_occupied_tiles() -> Array:
	#print("Road tiles: %s" % road_tiles.keys())
	return road_tiles.keys()

func has_road(tile_pos) -> bool:
	return tile_pos in road_tiles


func _process(delta: float) -> void:
	pass