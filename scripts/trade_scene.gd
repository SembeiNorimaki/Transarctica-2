extends Control
class_name TradeScene

# Managers
@onready var horizontal_train_manager = $Managers/HorizontalTrainManager
@onready var resource_manager = $Managers/ResourceManager


# Containers
@onready var city_resource_container = $Containers/CityResourceContainer
@onready var train_resource_container = $Containers/TrainResourceContainer


# Controllers

# Services
@onready var tile_occupancy_service = $Services/TileOccupancyService
@onready var grid_service = $Services/GridService
@onready var trade_service = $Services/TradeService

@onready var trade_menu = $TradeMenu

# Overlays

# Labels

# Map 
@onready var map_root = $MapRoot

var city_data = {
	"resources": {
		"caviar": 2,
		"alcohol": 5
	}
}


#region initialization
func _ready() -> void:
	_inject_services()
	_load_map("level_1")
	initialize({})

func initialize(city_data_):
	#city_data = city_data_
	#initialize_resources(city_data_)
	return

	
	# var resource_tileset = map_root.get_node("TradeCity").get_node("Resources")
	
	# var idx = 0
	# for resource_name in city_data["resources"].keys():
	# 	var qty = city_data["resources"][resource_name]
	# 	var tile = resource_spawn_tiles[idx]
	# 	for i in range(qty):
	# 		resource_tileset.set_cell(tile, 0, resource_name_to_atlas_coords[resource_name])
	# 		tile += Vector2i(1, 0)
	# 	idx += 1
	
	# print("Trade scene initialize with data: ", city_data)


func _inject_services():
	# Managers
	horizontal_train_manager.tile_occupancy_service = tile_occupancy_service
	horizontal_train_manager.grid_service = grid_service
	resource_manager.grid_service = grid_service
	resource_manager.tile_occupancy_service = tile_occupancy_service
	
#endregion

#region Map Loading
func _load_map(map_name: String) -> void:
	grid_service.set_tile_size(Vector2i(128, 64))
	_spawn_train(Vector2(5, 3))
	_spawn_resources()


func _spawn_resources():
	var idx = 0
	for resource_name in city_data["resources"].keys():
		var qty = city_data["resources"][resource_name]
		resource_manager.spawn_resource(resource_name, qty)
		city_resource_container.add_resource_amount(resource_name, qty)
		idx += 1
	print("Finished spawning resources")
	print(city_resource_container.get_all_info())


func _spawn_train(initial_tile: Vector2):
	horizontal_train_manager.spawn_train(initial_tile)

#endregion

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_local_mouse_position()
		var tile = grid_service.world_to_tile(mouse_pos)
		_handle_click(tile, event.button_index)
	
func _handle_click(tile, button_index):
	print("Clicked tile %s" % tile)

	# check if the tile has a reasource
	var resource = resource_manager.get_resource_in_tile(tile)
	if resource:
		print("Clicked a resource %s" % resource)
		trade_menu.initialize({
			"name": "caviar",
			"available": 3,
			"price": 4,
			"train_space": 10,
		})
		trade_menu.visible = true
	else:
		trade_menu.visible = false
