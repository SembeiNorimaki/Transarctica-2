extends Node
class_name CitiesManager

# Injected by NavigationScene
var rail_service: RailService

var cities = {} # EntryTile -> {name, city_tile}

func spawn_city(tile: Vector2i) -> void:
	#var city_name = "City_%s_%s" % [tile.x, tile.y]
	var city_name = GameState.cities_by_location[str(tile.x) + "," + str(tile.y)]
	# print("CityManager: Spawn %s" % city_name)
	var entry_tile = _compute_entry_tile(tile)
	cities[entry_tile] = {"name": city_name, "city_tile": tile}

func _compute_entry_tile(tile: Vector2i):
	for offset in [Vector2i(0, 2), Vector2i(0, -2), Vector2i(2, 0), Vector2i(-2, 0)]:
		if rail_service.has_rail(tile + offset):
			return tile + offset
	return tile + Vector2i(0, 2)

func get_city_by_entry_tile(tile: Vector2i) -> Dictionary:
	return cities.get(tile, null)

func is_entry_tile(tile: Vector2i) -> bool:
	return tile in cities
