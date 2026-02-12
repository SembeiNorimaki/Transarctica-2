extends Node
class_name CitiesManager

var cities = {} # EntryTile -> {name, city_tile}

func spawn_city(tile: Vector2i) -> void:
    var city_name = "City_%s_%s" % [tile.x, tile.y]
    print("CityManager: Spawn %s" % city_name)
    var entry_tile = _compute_entry_tile(tile)
    cities[entry_tile] = {"name": city_name, "city_tile": tile}

func _compute_entry_tile(tile: Vector2i):
    return tile + Vector2i(0, 2)

func get_city_by_entry_tile(tile: Vector2i) -> Dictionary:
    return cities.get(tile, null)

func is_entry_tile(tile: Vector2i) -> bool:
    return tile in cities
