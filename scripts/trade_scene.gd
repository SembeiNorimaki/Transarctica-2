extends Control
class_name TradeScene

# Managers
@onready var horizontal_train_manager = $Managers/HorizontalTrainManager
@onready var resource_manager = $Managers/ResourceManager


# Containers
@onready var city_resource_container = $Containers/CityResourceContainer
@onready var train_resource_container = $Containers/TrainResourceContainer
@onready var train_container = $Containers/Trains


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
@onready var cityname_label = $Title/Label

# Map 
@onready var map_root = $MapRoot

var city_data = {
	"resources": {
		"caviar": 2,
		"alcohol": 5
	}
}


const source_id_to_name = {
	0: "City",
	1: "City",
	2: "BrickFactory",
	3: "ChemicalPlant",
	4: "ClayMine",
	5: "CoalMine",
	6: "ContainerPort",
	7: "CopperMine",
	8: "Farm"
}

var city_tile = Vector2i(19, 20)

#region initialization
func _ready() -> void:
	_inject_services()
	_connect_signals()
	_load_map("level_1")
	#call_deferred("initialize", "Barcelona")

func initialize(name: String):
	print("Initializing city: %s" % name)
	cityname_label.text = name
	camera_controller.center_at_tile(Vector2i(20, 20))
	
	# check if it's a city or an industry
	if name in GameState.state.cities:
		print("It's a city")
		load_city_resources_from_game_state(name)
	elif name in GameState.state.industries:
		print("It's an industry")
		# change the city tile for the corresponding industry type
		var cities_tilemap: TileMapLayer = map_root.get_node("TradeCity").get_node("Cities")
		cities_tilemap.set_cell(city_tile, )
		load_industry_resources_from_game_state(name)
	else:
		print("Error, %s not found in GameState" % name)
		return

	
	load_train_from_game_state()
	trade_service.set_context(city_resource_container, train_resource_container)


func load_city_resources_from_game_state(city_name: String):
	if not GameState.state.cities.has(city_name):
		print("Error, %s not found in GameState" % city_name)
		return

	for resource_name in GameState.state.cities[city_name].TradeResources:
		var qty = GameState.state.cities[city_name].TradeResources[resource_name].Quantity
		var sell_price = GameState.state.cities[city_name].TradeResources[resource_name].SellPrice
		var buy_price = GameState.state.cities[city_name].TradeResources[resource_name].BuyPrice
		var max_capacity = 999

		resource_manager.spawn_resource(resource_name, qty, "trade")
		city_resource_container.initialize_resource(resource_name, qty, buy_price, sell_price, max_capacity)

func load_industry_resources_from_game_state(industry_name: String):
	if not GameState.state.industries.has(industry_name):
		print("Error, %s not found in GameState" % industry_name)
		return

	for resource_name in GameState.state.industries[industry_name].Requires:
		resource_manager.spawn_resource(resource_name, 0, "requires")
		#city_resource_container.initialize_resource(resource_name, qty, buy_price, sell_price, max_capacity)
	for resource_name in GameState.state.industries[industry_name].Produces:
		resource_manager.spawn_resource(resource_name, 0, "produces")


func load_train_from_game_state():
	print("Loading from game state")
	var initial_tile = Vector2i(12, 12)
	var horizontal_train = horizontal_train_manager.spawn_train(initial_tile, "Player")
	add_child(horizontal_train)
	print("Spawned horizontal train at tile: %s" % initial_tile)


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

	trade_menu.on_button_clicked.connect(trade_service.execute_transaction)

#endregion

#region Map Loading
func _load_map(map_name: String) -> void:
	grid_service.set_tile_size(Vector2i(128, 64))

	
#endregion

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_local_mouse_position()
		
		var clicked_traffic_light: bool = traffic_light.check_click(mouse_pos)
		if clicked_traffic_light:
			_handle_traffic_light_click()
			return
		
		var clicked_wagon_id = horizontal_train_manager.check_wagon_click(mouse_pos)
		if clicked_wagon_id != -1:
			_handle_wagon_click(clicked_wagon_id)
			return
		
		var tile = grid_service.world_to_tile(mouse_pos)
		_handle_tile_click(tile, event.button_index)
	elif event.is_action_pressed("right"):
		print("Right pressed")
		horizontal_train_manager.gear_up()
	elif event.is_action_pressed("left"):
		print("Left pressed")
		horizontal_train_manager.gear_down()
		

func _handle_traffic_light_click():
	print("Traffic light clicked")
	traffic_light.toggle()
	SceneManager.leave_city()

func _handle_wagon_click(wagon_id):
	var resource_info = train_resource_container.get_wagon_info(wagon_id)

	print("wagon resource info: ", resource_info)
	var sell_price = city_resource_container.get_sell_price(resource_info.resource_name)

	#var wagon_resource = train_resource_container.get_wagon_current_resource(wagon_id)
	# if the wagon is empty, do not open the menu
	#if wagon_resource == "":
		#trade_menu.visible = false
		#return

	#var qty = train_resource_container.get_wagon_resource_qty(wagon_id)
	#print("Clicked wagon %s wich contains %s amounts of %s" % [wagon_id, qty, wagon_resource])
	trade_service.set_transaction_data(resource_info.resource_name, "sell", 1, sell_price)

	var trade_menu_info = {
		"resource_name": resource_info.resource_name,
		"qty": 1,
		"sell_price": sell_price,
		"train_space": 0
	}
	trade_menu.show_sell_mode(trade_menu_info)


func _handle_tile_click(tile, button_index):
	print("Clicked tile %s" % tile)
	# check if the tile has a reasource
	var resource = resource_manager.get_resource_in_tile(tile)
	if resource:
		_handle_city_resource_click(resource)
	else:
		trade_menu.visible = false

func _handle_city_resource_click(resource):
	var resource_name = resource.resource_name
	var resource_info = city_resource_container.get_resource_info(resource_name)
	print("city resource info: ", resource_info)
	trade_service.set_transaction_data(resource_name, "buy", 1, resource_info.buy_price)
	trade_menu.show_buy_mode(resource_info)


# func _on_button_pressed() -> void:
# 	var resource_info = trade_menu.get_info()
# 	print("buying 1 unit of %s" % resource_info.resource_name)
# 	var successful = trade_service.buy(resource_info.resource_name, 1)
# 	if successful:
# 		trade_menu.update_resource(resource_info.resource_name, resource_info.available - 1, resource_info.price, resource_info.train_space - 1)


func _on_city_resource_amount_changed(resource: String, qty: int):
	resource_manager.update_resource_qty(resource, qty)

func _on_train_money_changed(money: int):
	horizontal_train_manager._on_train_money_changed(money)
