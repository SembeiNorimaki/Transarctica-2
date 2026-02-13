extends Node2D
class_name TradeScene

# Managers
@onready var horizontal_train_manager = $Managers/HorizontalTrainManager

# Containers

# Controllers

# Services
@onready var tile_occupancy_service = $Services/TileOccupancyService
@onready var grid_service = $Services/GridService

# Overlays

# Labels

#region initialization
func _ready() -> void:
	_inject_services()
	_load_map("level_1")

func _inject_services():
	# Managers
	horizontal_train_manager.tile_occupancy_service = tile_occupancy_service
	horizontal_train_manager.grid_service = grid_service
	
#endregion

#region Map Loading
func _load_map(map_name: String) -> void:
	grid_service.set_tile_size(Vector2i(128, 64))
	_spawn_train(Vector2(15, 2.5))

func _spawn_train(initial_tile: Vector2):
	horizontal_train_manager.spawn_train(initial_tile)

#endregion
