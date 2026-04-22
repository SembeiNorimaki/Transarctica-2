"""
Tile Occupancy Service

This service is responsible for managing the occupancy of tiles on the map.
It keeps track of which tiles are occupied by which entities and provides
methods to query and update the occupancy of tiles.

_occupied_tiles : Dictionary of  Tile (Vector2i) -> Array[Entity]


"""


extends Node

class_name TileOccupancyService

var tile_size = Vector2i(70, 36)

var _occupied_tiles := {}

func _ready() -> void:
    pass


func register_footprint(anchor: Vector2i, offsets: Array[Vector2i], entity: Object) -> void:
    for offset in offsets:
        var tile = anchor + offset
        register(tile, entity)

func unregister_footprint(anchor: Vector2i, offsets: Array[Vector2i], entity: Object) -> void:
    for offset in offsets:
        var tile = anchor + offset
        unregister(tile, entity)

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
func get_occupied_tiles() -> Dictionary:
    return _occupied_tiles

func get_entities(tile: Vector2i) -> Array:
    return _occupied_tiles.get(tile, [])

func get_units(tile: Vector2i) -> Array[Unit]:
    var units: Array[Unit] = []
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

func get_resources(tile: Vector2i) -> Array:
    var resources = []
    for entity in get_entities(tile):
        if entity is Resource: # This doesnt work. I should rename to TradeResource
            resources.append(entity)
    return resources


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

func is_occupied_static(tile: Vector2i) -> bool:
    if _occupied_tiles.has(tile):
        for entity in _occupied_tiles[tile]:
            if entity is not Unit:
                return true
    return false

func is_footprint_free(anchor: Vector2i, offsets: Array[Vector2i]) -> bool:
    for offset in offsets:
        var tile = anchor + offset
        if is_occupied(tile):
            return false
    return true

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
