extends Node2D

# Services
@onready var grid_service = $Services/GridService
@onready var rail_service = $Services/RailService

# Map 
@onready var map_root = $MapRoot
@onready var exploration_layer = $MapRoot/ExplorationLayer

#Entities
@onready var player_train = $Containers/Trains/PlayerTrain

func _ready() -> void:
    grid_service.set_tile_size(Vector2i(128, 64))
    _inject_services()
    _wire_signals()

func _inject_services():
    player_train.grid_service = grid_service
    rail_service.rails_tilemap = $MapRoot/World1/Rails

func _wire_signals():
    player_train.tile_changed.connect(_on_player_train_tile_changed)

func _on_player_train_tile_changed(from_tile: Vector2i, to_tile: Vector2i) -> void:
    rail_service.build_rail(to_tile)
