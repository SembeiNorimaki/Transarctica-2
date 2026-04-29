extends Control
class_name TradeScene

# Managers
@onready var horizontal_train_manager = $Managers/HorizontalTrainManager
@onready var resource_manager = $Managers/ResourceManager


# Containers
@onready var city_resource_container = $Containers/CityResourceContainer
@onready var train_resource_container = $Containers/TrainResourceContainer


# Controllers
@onready var camera_controller = $Controllers/CameraController

# Services
@onready var tile_occupancy_service = $Services/TileOccupancyService
@onready var grid_service = $Services/GridService
@onready var trade_service = $Services/TradeService

@onready var trade_menu = $TradeMenu
@onready var traffic_light = $Containers/TrafficLight
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
	_connect_signals()
	_load_map("level_1")
	call_deferred("initialize", {})

func initialize(city_data_):
	camera_controller.center_at_tile(Vector2i(20, 20))
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
	horizontal_train_manager.train_resource_container = train_resource_container
	resource_manager.grid_service = grid_service
	resource_manager.tile_occupancy_service = tile_occupancy_service

	# Controllers
	camera_controller.grid_service = grid_service

func _connect_signals():
	train_resource_container.wagon_resource_type_changed.connect(horizontal_train_manager._on_wagon_resource_type_changed)
	train_resource_container.wagon_resource_amount_changed.connect(horizontal_train_manager._on_wagon_resource_amount_changed)
	city_resource_container.city_resource_amount_changed.connect(_on_city_resource_amount_changed)
	train_resource_container.train_money_changed.connect(_on_train_money_changed)

#endregion

#region Map Loading
func _load_map(map_name: String) -> void:
	grid_service.set_tile_size(Vector2i(128, 64))
	_spawn_train(Vector2(27, 22))
	_spawn_resources()


func _spawn_resources():
	var idx = 0
	for resource_name in city_data["resources"].keys():
		var qty = city_data["resources"][resource_name]
		var buy_price = 1
		var sell_price = 1
		var max_capacity = 200
		resource_manager.spawn_resource(resource_name, qty)
		city_resource_container.initialize_resource(resource_name, qty, buy_price, sell_price, max_capacity)
		
		# this should not be here but in the train initialization, only here for testing
		train_resource_container.initialize_resource(resource_name, 0, 100)
		
		idx += 1
	print("Finished spawning resources")
	print(city_resource_container.get_all_info())


func _spawn_train(initial_tile: Vector2):
	horizontal_train_manager.spawn_train(initial_tile)

#endregion

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_local_mouse_position()
		
		var clicked_traffic_light : bool = traffic_light.check_click(mouse_pos)
		if clicked_traffic_light:
			_handle_traffic_light_click()
			return
		
		var clicked_wagon_id = horizontal_train_manager.check_wagon_click(mouse_pos)
		if clicked_wagon_id != -1:
			_handle_wagon_click(clicked_wagon_id)
			return
		
		var tile = grid_service.world_to_tile(mouse_pos)
		_handle_tile_click(tile, event.button_index)

func _handle_traffic_light_click():
	print("Traffic light clicked")
	traffic_light.toggle()

func _handle_wagon_click(wagon_id):
	var wagon_resource = train_resource_container.get_wagon_current_resource(wagon_id)
	# if the wagon is empty, do not open the menu
	if wagon_resource == "":
		trade_menu.visible = false
		return

	var qty = train_resource_container.get_wagon_resource_qty(wagon_id)
	print("Clicked wagon %s wich contains %s amounts of %s" % [wagon_id, qty, wagon_resource])

	trade_menu.initialize({
		"name": wagon_resource,
		"available": qty,
		"price": 4,
		"train_space": 10,
	})
	trade_menu.visible = true

func _handle_tile_click(tile, button_index):
	print("Clicked tile %s" % tile)

	# check if the tile has a reasource
	var resource = resource_manager.get_resource_in_tile(tile)
	if resource:
		var resource_name = resource.resource_name
		print("Clicked a resource %s" % resource_name)
		var qty = city_resource_container.get_available_qty(resource_name)
		trade_menu.initialize({
			"name": resource_name,
			"available": qty,
			"price": 4,
			"train_space": 10,
		})
		trade_menu.visible = true
	else:
		trade_menu.visible = false


func _on_button_pressed() -> void:
	var resource_info = trade_menu.get_info()
	print("buying 1 unit of %s" % resource_info.resource_name)
	var successful = trade_service.buy(city_resource_container, train_resource_container, resource_info.resource_name, 1)
	if successful:
		trade_menu.update_resource(resource_info.resource_name, resource_info.available - 1, resource_info.price, resource_info.train_space - 1)


func _on_city_resource_amount_changed(resource: String, qty: int):
	resource_manager.update_resource_qty(resource, qty)

func _on_train_money_changed(money: int):
	horizontal_train_manager._on_train_money_changed(money)
	
