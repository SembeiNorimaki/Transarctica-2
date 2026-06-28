extends Control
class_name TradeScene

#region onready
# Managers
@onready var horizontal_train_manager = $Managers/HorizontalTrainManager

# resource_manager spawns crates, knows where they are and has the xpos_to_resource_name  method
@onready var resource_manager = $Managers/ResourceManager

# Inventories
@onready var city_inventory = $Services/TradeService/CityInventory
@onready var train_inventory = $Services/TradeService/TrainInventory
@onready var loader_inventory = $Services/TradeService/LoaderInventory

#Containers
@onready var train_container = $Containers/Trains
@onready var traffic_light = $Containers/TrafficLight

# Controllers
@onready var camera_controller = $Controllers/CameraController

# Services
@onready var tile_occupancy_service = $Services/TileOccupancyService
@onready var grid_service = $Services/GridService
@onready var trade_service = $Services/TradeService

#@onready var trade_menu = $TradeMenu
# Overlays

# Labels
@onready var cityname_label = $Title/Label

# Map 
@onready var map_root = $MapRoot

#@onready var loader_vehicle: LoaderVehicle = $Containers/LoaderVehicle
@onready var loader_vehicle = $Containers/TankBase.loader_component

@onready var hud = $TradeHUD
#endregion

var is_intro := true
var is_outro := false
var horizontal_train: HorizontalTrain = null

# TODO: This shouldn't be here
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

# the tile where the industry is placed
var city_tile = Vector2i(19, 20)

const MUSIC_TRADE: AudioStream = preload("res://assets/audio/city1.wav")

#region initialization
func _ready() -> void:
    _inject_services()
    _connect_signals()
    _load_map("trade_city")

    if get_tree().current_scene == self:
        print("TradeScene is running standalone")
        call_deferred("initialize", "Paris")
    else:
        print("TradeScene was instantiated by SceneManager")

    AudioService.play_music(MUSIC_TRADE, 0.0)
    

# things to do when entering the scene
func initialize(name: String):
    print("Initializing city: %s" % name)
    cityname_label.text = name
    
    
    # check if it's a city or an industry
    if name in GameState.get_all_city_names():
        print("It's a city")
        load_city_resources_from_game_state(name)
    elif name in GameState.get_all_industry_names():
        print("It's an industry")
        # change the city tile for the corresponding industry type
        # var cities_tilemap: TileMapLayer = map_root.get_node("TradeCity").get_node("Cities")
        # cities_tilemap.set_cell(city_tile, )
        # load_industry_resources_from_game_state(name)
    else:
        print("Error, %s not found in GameState" % name)
        return

    load_train_from_game_state()
    load_loader_vehicle()

# things to do when leaving the scene
func leave_scene():
    # basically save everythong in the GameState
    # Save train: Money and Cargos
    # Save city: Resources and prices
    pass


func load_city_resources_from_game_state(city_name: String):
    # This function uses the structure returned by GameState.get_city_by_name
    # TradeResources: { resource_name: { Quantity: x, SellPrice: x, BuyPrice: x} }
    var city_data = GameState.get_city_by_name(city_name)
    if not city_data:
        print("Error, %s not found in GameState" % city_name)
        return
    
    city_inventory.city_name = city_name
    for resource_name in city_data.TradeResources:
        var qty = city_data.TradeResources[resource_name].Quantity
        var sell_price = city_data.TradeResources[resource_name].SellPrice
        var buy_price = city_data.TradeResources[resource_name].BuyPrice
        var max_capacity = 999

        #resource_manager.spawn_resource(resource_name, qty, "trade")
        resource_manager.spawn_crate(resource_name, qty, "trade")
        city_inventory.initialize_resource(resource_name, qty, buy_price, sell_price, max_capacity)

func load_industry_resources_from_game_state(industry_name: String):
    if not GameState.state.industries.has(industry_name):
        print("Error, %s not found in GameState" % industry_name)
        return

    for resource_name in GameState.state.industries[industry_name].Requires:
        resource_manager.spawn_resource(resource_name, 0, "requires")
        #city_inventory.initialize_resource(resource_name, qty, buy_price, sell_price, max_capacity)
    for resource_name in GameState.state.industries[industry_name].Produces:
        resource_manager.spawn_resource(resource_name, 0, "produces")


func load_train_from_game_state():
    print("Loading horizontal train from game state")
    var initial_tile = Vector2(-3.2, 4)
    var train_data = GameState.get_player_train()
    horizontal_train = horizontal_train_manager.spawn_train(initial_tile, train_data)
    horizontal_train.set_speed(horizontal_train.max_speed)
    train_container.add_child(horizontal_train)
    print("Spawned horizontal train at tile: %s" % initial_tile)

func load_loader_vehicle():
    loader_vehicle.call_deferred("initialize")

func _inject_services():
    # Managers
    horizontal_train_manager.tile_occupancy_service = tile_occupancy_service
    horizontal_train_manager.grid_service = grid_service
    horizontal_train_manager.train_inventory = train_inventory

    resource_manager.grid_service = grid_service
    resource_manager.tile_occupancy_service = tile_occupancy_service

    # Controllers
    camera_controller.grid_service = grid_service

    loader_vehicle.camera_controller = camera_controller
    $Containers/TankBase
    

func _connect_signals():
    train_inventory.wagon_resource_type_changed.connect(horizontal_train_manager._on_wagon_resource_type_changed)
    train_inventory.wagon_resource_amount_changed.connect(horizontal_train_manager._on_wagon_resource_amount_changed)
    city_inventory.city_resource_amount_changed.connect(_on_city_resource_amount_changed)
    train_inventory.train_money_changed.connect(_on_train_money_changed)

    #trade_menu.on_button_clicked.connect(trade_service.execute_transaction)

#endregion

#region process
func _process(delta: float) -> void:
    if is_intro:
        _process_intro()
    elif is_outro:
        _process_outro()

    hud.update_gold(GameState.state.money)
    #hud.update_fuel(GameState.state.fuel)
    

func _process_intro():
    if horizontal_train.global_position.x > 0:
        horizontal_train.gear_down()
        is_intro = false

func _process_outro():
    if horizontal_train.global_position.x > 2000:
        SceneManager.leave_city()
#endregion

#region Map Loading
func _load_map(map_name: String) -> void:
    var map_path = "res://scenes/maps/%s.tscn" % map_name
    if not ResourceLoader.exists(map_path):
        push_error("Map not found for map: %s at path: %s" % [map_name, map_path])
    # remove existing map
    if get_node("MapRoot").get_child_count() > 0:
        var existing_map = get_node("MapRoot").get_child(0)
        map_root.remove_child(existing_map)
        existing_map.free()
    # load new map
    var new_map = load(map_path).instantiate()
    map_root.add_child(new_map)
    map_root.move_child(new_map, 0)

    # Set tilesize to grid service and tile occupancy service
    var tile_size = new_map.get_node("Terrain").tile_set.tile_size
    grid_service.set_tile_size(tile_size)
    tile_occupancy_service.tile_size = tile_size

    grid_service.map_size = new_map.get_node("Terrain").get_used_rect().size
    print("Map size %s" % grid_service.map_size)


    #grid_service.set_tile_size(Vector2i(128, 64))

    
#endregion

#region input
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
        #loader_vehicle.gear_up()
    elif event.is_action_pressed("left"):
        print("Left pressed")
        #loader_vehicle.gear_down()
    elif event.is_action_pressed("i"):
        on_i_pressed()
    elif event.is_action_pressed("k"):
        on_k_pressed()
    elif event.is_action_pressed("u"):
        on_u_pressed()
    elif event.is_action_pressed("j"):
        on_j_pressed()
    elif event.is_action_pressed("esc"):
        on_esc_pressed()

func _handle_traffic_light_click():
    print("Traffic light clicked")
    traffic_light.toggle()
    horizontal_train.gear_up()
    is_outro = true
    
func _handle_wagon_click(wagon_id):
    pass
    #var resource_info = train_inventory.get_wagon_info(wagon_id)

    #print("wagon resource info: ", resource_info)
    #var sell_price = city_inventory.get_sell_price(resource_info.resource_name)

    #var wagon_resource = train_inventory.get_wagon_current_resource(wagon_id)
    # if the wagon is empty, do not open the menu
    #if wagon_resource == "":
        #trade_menu.visible = false
        #return

    #var qty = train_inventory.get_wagon_resource_qty(wagon_id)
    #print("Clicked wagon %s wich contains %s amounts of %s" % [wagon_id, qty, wagon_resource])
    #trade_service.set_transaction_data(resource_info.resource_name, "sell", 1, sell_price)

    # var trade_menu_info = {
    #     "resource_name": resource_info.resource_name,
    #     "qty": 1,
    #     "sell_price": sell_price,
    #     "train_space": 0
    # }
    # trade_menu.show_sell_mode(trade_menu_info)

func _handle_tile_click(tile, button_index):
    print("Clicked tile %s" % tile)
    # check if the tile has a reasource
    # var resource = resource_manager.get_resource_in_tile(tile)
    # if resource:
    #     _handle_city_resource_click(resource)
    # else:
    #     trade_menu.visible = false

func _handle_city_resource_click(resource):
    pass
    # var resource_name = resource.resource_name
    # var resource_info = city_inventory.get_resource_info(resource_name)
    # print("city resource info: ", resource_info)
    # trade_service.set_transaction_data(resource_name, "buy", 1, resource_info.buy_price)
    # trade_menu.show_buy_mode(resource_info)

func on_esc_pressed():
    # esc returns the loaded crates to the city
    var qty = loader_inventory.get_qty()
    var resource_name = loader_inventory.get_resource_type()
    var price_per_crate = city_inventory.get_buy_price(resource_name)
    var train_money = train_inventory.money

    var new_money = loader_inventory.undo_to_city(qty, price_per_crate, train_money)
    
    if new_money != train_inventory.money:
        loader_vehicle.set_crate_qty(0)
        train_inventory.money = new_money
        city_inventory.add_resource_amount(resource_name, qty)

    hud.update_gold(train_inventory.money)


# u: Train -> Loader        
func on_u_pressed():
    var wagon_idx = horizontal_train_manager.player_train.xpos_to_wagon_idx(loader_vehicle.global_position.x)
    var qty = 1
    var success = trade_service.transfer_from_train_to_loader(wagon_idx, qty)
    if success:
        var wagon = horizontal_train_manager.player_train.wagons[wagon_idx]
        # TODO: This fails when wagon becomes empty
        var resource_name = train_inventory.get_wagon_current_resource(wagon_idx)
        
        wagon.open_doors()
        await get_tree().create_timer(1).timeout
        loader_vehicle.load_crate(resource_name)
        wagon.close_doors()
        hud.update_gold(GameState.get_money())


# j: Loader -> City
func on_j_pressed():
    var resource_name = resource_manager.xpos_to_resource_name(loader_vehicle.global_position.x)
    var qty = 1
    var success = trade_service.transfer_from_loader_to_city(resource_name, qty)
    if success:
        loader_vehicle.unload_crate()
        hud.update_gold(GameState.get_money())


# k: City -> Loader        
func on_k_pressed():
    var resource_name = resource_manager.xpos_to_resource_name(loader_vehicle.global_position.x)
    var qty = 1
    var success = trade_service.transfer_from_city_to_loader(resource_name, qty)
    if success:
        loader_vehicle.load_crate(resource_name)
        hud.update_gold(GameState.get_money())

    
# i: Loader -> Train
func on_i_pressed():
    var wagon_idx = horizontal_train_manager.player_train.xpos_to_wagon_idx(loader_vehicle.global_position.x)
    var qty = 1
    var success = trade_service.transfer_from_loader_to_train(wagon_idx, qty)
    if success:
        var wagon = horizontal_train_manager.player_train.wagons[wagon_idx]
        var resource_name = loader_inventory.get_resource_type()

        wagon.open_doors()
        await get_tree().create_timer(1).timeout
        loader_vehicle.unload_crate()
        wagon.close_doors()

        hud.update_gold(GameState.get_money())


#endregion

#region callbacks
func _on_city_resource_amount_changed(resource: String, qty: int):
    resource_manager.update_resource_qty(resource, qty)

func _on_train_money_changed(money: int):
    horizontal_train_manager._on_train_money_changed(money)
#endregion
