extends Node

class_name TileOccupancyService

var tile_size = Vector2i(70, 36)

var _occupied_tiles := {}

func _ready() -> void:
    pass

func get_occupied_tiles() -> Dictionary:
    return _occupied_tiles

func register(tile: Vector2i, entity: Object) -> void:
    var list = _occupied_tiles.get(tile)
    if list == null:
        list = []
        _occupied_tiles[tile] = list
    list.append(entity)

func unregister(tile: Vector2i, entity: Object) -> void:
    var list = _occupied_tiles.get(tile)
    if list == null:
        return
    list.erase(entity)
    if list.is_empty():
        _occupied_tiles.erase(tile)


#region QUERIES
func get_entities(tile: Vector2i) -> Array:
    return _occupied_tiles.get(tile, [])

func get_units(tile: Vector2i) -> Array:
    var units = []
    for entity in get_entities(tile):
        if entity is Unit:
            units.append(entity)
    return units

func get_buildings(tile: Vector2i) -> Array:
    var buildings = []
    for entity in get_entities(tile):
        if entity is Building:
            buildings.append(entity)
    return buildings

func get_walls(tile: Vector2i) -> Array:
    var walls = []
    for entity in get_entities(tile):
        if entity is Wall:
            walls.append(entity)
    return walls

func get_roads(tile: Vector2i) -> Array:
    var roads = []
    for entity in get_entities(tile):
        if entity is String and entity == "road":
            roads.append(entity)
    return roads

func is_occupied(tile: Vector2i) -> bool:
    return _occupied_tiles.has(tile)
    
func is_blocked(tile: Vector2i) -> bool:
    return is_occupied(tile)
#endregion

# DEBUGGING HELPERS
func get_all_occupied_tiles() -> Array:
    return _occupied_tiles.keys()

func get_all_entities() -> Array:
    var entities = []
    for tile in _occupied_tiles.values():
        entities.append(tile)
    return entities
