extends Control
class_name TradeScene

# Managers
@onready var horizontal_train_manager = $Managers/HorizontalTrainManager
@onready var resource_manager = $Managers/ResourceManager


# Containers
@onready var city_resource_container = $Containers/CityResourceContainer
@onready var train_resource_container = $Containers/TrainResourceContainer
@onready var loader_resource_container = $Containers/LoaderResourceContainer
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

@onready var loader_vehicle: LoaderVehicle = $Containers/LoaderVehicle


var is_intro := true
var is_outro := false
var horizontal_train: HorizontalTrain = null


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
	call_deferred("initialize", "Barcelona")

func initialize(name: String):
	print("Initializing city: %s" % name)
	cityname_label.text = name
	
	
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
	load_loader_vehicle()
	trade_service.set_context(city_resource_container, train_resource_container, name)

func _process(delta: float) -> void:
	if is_intro:
		_process_intro()
	elif is_outro:
		_process_outro()
	

func load_city_resources_from_game_state(city_name: String):
	if not GameState.state.cities.has(city_name):
		print("Error, %s not found in GameState" % city_name)
		return

	for resource_name in GameState.state.cities[city_name].TradeResources:
		var qty = GameState.state.cities[city_name].TradeResources[resource_name].Quantity
		var sell_price = GameState.state.cities[city_name].TradeResources[resource_name].SellPrice
		var buy_price = GameState.state.cities[city_name].TradeResources[resource_name].BuyPrice
		var max_capacity = 999

		#resource_manager.spawn_resource(resource_name, qty, "trade")
		resource_manager.spawn_crate(resource_name, qty, "trade")

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
	var initial_tile = Vector2(-3.2, 4)
	horizontal_train = horizontal_train_manager.spawn_train(initial_tile, "Player")
	horizontal_train.set_speed(horizontal_train.max_speed)
	add_child(horizontal_train)
	print("Spawned horizontal train at tile: %s" % initial_tile)

func load_loader_vehicle():
	loader_vehicle.call_deferred("initialize")

func _inject_services():
	# Managers
	horizontal_train_manager.tile_occupancy_service = tile_occupancy_service
	horizontal_train_manager.grid_service = grid_service
	horizontal_train_manager.train_resource_container = train_resource_container

	resource_manager.grid_service = grid_service
	resource_manager.tile_occupancy_service = tile_occupancy_service

	# Controllers
	camera_controller.grid_service = grid_service

	loader_vehicle.camera_controller = camera_controller
	

func _connect_signals():
	train_resource_container.wagon_resource_type_changed.connect(horizontal_train_manager._on_wagon_resource_type_changed)
	train_resource_container.wagon_resource_amount_changed.connect(horizontal_train_manager._on_wagon_resource_amount_changed)
	city_resource_container.city_resource_amount_changed.connect(_on_city_resource_amount_changed)
	train_resource_container.train_money_changed.connect(_on_train_money_changed)

	trade_menu.on_button_clicked.connect(trade_service.execute_transaction)

#endregion

func _process_intro():
	if horizontal_train.global_position.x > 0:
		horizontal_train.gear_down()
		is_intro = false

func _process_outro():
	if horizontal_train.global_position.x > 2000:
		SceneManager.leave_city()

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
		loader_vehicle.gear_up()
	elif event.is_action_pressed("left"):
		print("Left pressed")
		loader_vehicle.gear_down()
	elif event.is_action_pressed("i"):
		on_i_pressed()
	elif event.is_action_pressed("k"):
		on_k_pressed()
	elif event.is_action_pressed("u"):
		on_u_pressed()

		
func _handle_traffic_light_click():
	print("Traffic light clicked")
	traffic_light.toggle()
	horizontal_train.gear_up()
	is_outro = true
	

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


# This functions handle the loading unloading of resources by the loader vehicle


func on_i_pressed():
	# i transfers a resource from the train to the loader
	var wagon_idx = horizontal_train_manager.player_train.xpos_to_wagon_idx(loader_vehicle.global_position.x)
	if wagon_idx == -1:
		return
	if loader_resource_container.is_full():
		return

	var wagon = horizontal_train_manager.player_train.wagons[wagon_idx]
	var resource_type = train_resource_container.get_wagon_current_resource(wagon_idx)
	
	if resource_type == "":
		return # wagon empty, nothing to unload
	
	wagon.open_doors()
	await get_tree().create_timer(1).timeout

	# Remove crate from wagon
	var removed = train_resource_container.remove_resource_qty_from_wagon(wagon_idx, 1)
	if removed:
		loader_resource_container.pick_from_wagon(resource_type, 1)
		loader_vehicle.load_crate(resource_type)
	wagon.close_doors()
	return

func on_u_pressed():
	# u transfers a resource from the loader to the train
	var wagon_idx = horizontal_train_manager.player_train.xpos_to_wagon_idx(loader_vehicle.global_position.x)
	if wagon_idx == -1:
		return
	if loader_resource_container.is_empty():
		return

	var wagon = horizontal_train_manager.player_train.wagons[wagon_idx]

	var resource_type = loader_resource_container.get_resource_type()
	# Must match wagon rules
	if not train_resource_container.wagon_can_store(wagon_idx, resource_type):
		return
	
	wagon.open_doors()
	await get_tree().create_timer(1).timeout

	# Move crate from loader to wagon
	loader_resource_container.finalize_into_wagon(1)
	loader_vehicle.unload_crate()
	train_resource_container.add_resource_qty_to_wagon(wagon_idx, resource_type, 1)

	wagon.close_doors()

	
func on_k_pressed():
	# k loads a resource from the city into the loader
	var resource_idx = resource_manager.xpos_to_resource_idx(loader_vehicle.global_position.x)
	
	if resource_idx == -1:
		return
	
	if loader_resource_container.is_full():
		return

	var resource_type = resource_manager.resources.keys()[resource_idx]
	var price = city_resource_container.get_buy_price(resource_type)

	var available_qty = city_resource_container.get_available_qty(resource_type)
	if available_qty == 0:
		return

	# Attempt to pick from city (money is subtracted here)
	var new_money = loader_resource_container.pick_from_city(
		resource_type,
		1,
		price,
		train_resource_container.money
	)

	# If money changed → pickup succeeded
	if new_money != train_resource_container.money:
		train_resource_container.money = new_money
		city_resource_container.remove_resource_amount(resource_type, 1)
		loader_vehicle.load_crate(resource_type)
		print("Picked 1 crate of %s from city" % resource_type)
	
		
	# # if Loader has crates → unload back to city (undo)
	# if loader_resource_container.origin == "city":
	#     var resource_type = loader_resource_container.resource_type
	#     var price = city_resource_container.get_buy_price(resource_type)

	#     var new_money = loader_resource_container.undo_to_city(1, price, train_resource_container.money)
	#     if new_money != train_resource_container.money:
	#         train_resource_container.money = new_money
	#         city_resource_container.add_resource_amount(resource_type, 1)
	#         print("Returned 1 crate of %s to city" % resource_type)
	#     return
	# # if Loader has crates from wagon → unload back to wagon area
	# if loader_resource_container.origin == "wagon":
	#     var resource_type = loader_resource_container.resource_type
	#     loader_resource_container.undo_to_wagon(1)
	#     city_resource_container.add_resource_amount(resource_type, 1)
	#     print("Returned 1 crate of %s to city (from wagon origin)" % resource_type)
	

func on_i_pressedOLD():
	# i acts on wagons, either loading or unloading them
	var wagon_idx = horizontal_train_manager.player_train.xpos_to_wagon_idx(loader_vehicle.global_position.x)
	if wagon_idx == -1:
		return
	
	if loader_vehicle.is_empty():
		# if the loader is empty, unload the selected wagon
		horizontal_train_manager.player_train.wagons[wagon_idx].open_doors()
		await get_tree().create_timer(1).timeout
		var resource_type = train_resource_container.get_wagon_current_resource(wagon_idx)
		train_resource_container.remove_resource_qty_from_wagon(wagon_idx, 1)
		loader_vehicle.load(resource_type)
		
		#var sell_price = city_resource_container.get_sell_price(resource_type)
		#trade_service.set_transaction_data(resource_type, "sell", 1, sell_price)
		#trade_service.execute_transaction(1)
		horizontal_train_manager.player_train.wagons[wagon_idx].close_doors()
	else:
		# if the loader is full, load the selected wagon
		horizontal_train_manager.player_train.wagons[wagon_idx].open_doors()
		await get_tree().create_timer(1).timeout

		#var resource_type = loader_vehicle.unload()
		var resource_type = loader_vehicle.unload_crate()
		print("Attempting to load wagon %s with %s from loader" % [wagon_idx, resource_type])
		train_resource_container.add_resource_qty_to_wagon(wagon_idx, resource_type, 1)
		print("Unloading %s from loader and loading it in wagon %s" % [resource_type, wagon_idx])
		horizontal_train_manager.player_train.wagons[wagon_idx].close_doors()

func on_k_pressedOLD():
	# k acts on resources either loading or unloading them from the loader vehicle
	var resource_idx = resource_manager.xpos_to_resource_idx(loader_vehicle.global_position.x)
	if resource_idx != -1:
		# if the loader is empty, load it with the selected resource
		var resource_type = resource_manager.resources.keys()[resource_idx]
		#loader_vehicle.load(resource_type)
		loader_vehicle.load_crate(resource_type)
		city_resource_container.remove_resource_amount(resource_type, 1)
		print("Loading %s to loader vehicle" % resource_type)
	else:
		# if the loader is full, unload it
		loader_vehicle.unload_crate()
		#var resource_type = loader_vehicle.unload()
		#city_resource_container.add_resource_amount(resource_type, 1)
