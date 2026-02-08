extends Node2D

# Services
@onready var grid_service = $Services/GridService
@onready var rail_service = $Services/RailService

# Map 
@onready var map_root = $MapRoot
@onready var exploration_layer = $MapRoot/ExplorationLayer

#Entities
@onready var player_train = $Containers/Trains/PlayerTrain

const ATLAS_TO_RAILNAME = {
    Vector2i(0, 0): "WE",
    Vector2i(1, 0): "NS",
    Vector2i(2, 0): "NW",
    Vector2i(3, 0): "",
    Vector2i(0, 1): "SE",
    Vector2i(1, 1): "NE",
    Vector2i(2, 1): "SW",
    Vector2i(3, 1): ""
}

func _ready() -> void:
    grid_service.set_tile_size(Vector2i(128, 64))
    _inject_services()
    _wire_signals()
    _load_map("world_1")

func _inject_services():
    player_train.grid_service = grid_service
    rail_service.rails_tilemap = $MapRoot/World1/Rails

func _wire_signals():
    player_train.tile_changed.connect(_on_player_train_tile_changed)

func _load_map(map_name: String) -> void:
    var rails_tilemap = map_root.get_node("World1").get_node("Rails")
    _build_rails_from_map(rails_tilemap)

func _build_rails_from_map(rails_tilemap: TileMapLayer) -> void:
    for tile in rails_tilemap.get_used_cells():
        var atlas_coords = rails_tilemap.get_cell_atlas_coords(tile)
        var source_id = rails_tilemap.get_cell_source_id(tile)
        var rail_name = ATLAS_TO_RAILNAME[atlas_coords]
        rail_service.spawn_rail(tile, rail_name)


func _on_player_train_tile_changed(from_tile: Vector2i, to_tile: Vector2i) -> void:
    rail_service.build_rail(to_tile)
