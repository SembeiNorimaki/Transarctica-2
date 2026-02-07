extends Node
class_name RailService

# Injected by NavigationScene
var rails_tilemap: TileMapLayer

var rail_graph := {}

func build_rail(tile: Vector2i) -> void:
    # Place the simplest rail, atlascoords (0, 0)
    rails_tilemap.set_cell(tile, 0, Vector2i(0, 0))

    # update internal graph
    _add_to_graph(tile)

func _has_rail(tile: Vector2i) -> bool:
    return rail_graph.has(tile)

func _add_to_graph(tile: Vector2i) -> void:
    rail_graph[tile] = []
