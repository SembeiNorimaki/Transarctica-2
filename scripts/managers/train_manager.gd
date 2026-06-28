# Manages navigation trains. The player one and the enemy ones

extends Node
class_name NavigationTrainManager

# ─────────────────────────────────────────────
#  NavigationTrainManager
#
#  Lifecycle & Setup:
#    _ready() -> void
#
#  Train Spawning:
#    spawn_train(tile_pos: Vector2i, ori: String, team: String)
#
#  Public API (Player Train Controls):
#    recenter_player_train()
#    reverse_train()
#    gear_toggle()
#
#  Signal Handlers & Internal Logic:
#    on_train_tile_changed(train: NavigationTrain, old_tile: Vector2i, new_tile: Vector2i) -> void
#    _check_tile_events(train: NavigationTrain, new_tile: Vector2i) -> void
#
#  Signals:
#    train_spawned(train: NavigationTrain)
#    train_tile_changed(train: NavigationTrain, old_tile: Vector2i, new_tile: Vector2i)
#    train_reached_destination(train: NavigationTrain)
#    train_reached_city(city_name: String)
# ─────────────────────────────────────────────

# Injected by NavigationScene
var rail_service: RailService
var grid_service: GridService
var cities_manager: CitiesManager
var camera_controller: CameraController
var exploration_layer

var next_train_id = {"Player": 0, "Enemy": 0}
var teams = ["Player", "Enemy"]
var trains := {"Player": [], "Enemy": []}

var TRAIN_SCENE = preload("res://scenes/entities/trains/navigation_train.tscn")

var camera_lock_to_engine = false ## Will lock camera to the engine when true

# TODO: Should not go here
var train_vision_offsets = [
    Vector2i(-2, -2),
    Vector2i(-2, -1),
    Vector2i(-2, 0),
    Vector2i(-2, 1),
    Vector2i(-2, 2),
    Vector2i(-1, -2),
    Vector2i(-1, -1),
    Vector2i(-1, 0),
    Vector2i(-1, 1),
    Vector2i(-1, 2),
    Vector2i(0, -2),
    Vector2i(0, -1),
    Vector2i(0, 0),
    Vector2i(0, 1),
    Vector2i(0, 2),
    Vector2i(1, -2),
    Vector2i(1, -1),
    Vector2i(1, 0),
    Vector2i(1, 1),
    Vector2i(1, 2),
    Vector2i(2, -2),
    Vector2i(2, -1),
    Vector2i(2, 0),
    Vector2i(2, 1),
    Vector2i(2, 2)
]

signal train_spawned(train)
signal train_tile_changed(train, old_tile, new_tile)
signal train_reached_destination(train)
signal train_reached_city(city_name)

func _ready() -> void:
    pass

#region train spawning
func spawn_train(tile_pos: Vector2i, ori: String, team: String):
	# print("Spawning a train at tile %s with orientation %s" % [tile_pos, ori])
	var id = "t%s%s" % [team[0], next_train_id[team]]
	next_train_id[team] += 1
	
	var train = TRAIN_SCENE.instantiate()

    # Dependency injection
    train.train_manager = self
    train.grid_service = grid_service
    train.rail_service = rail_service

    # connect signals
    train.train_tile_changed.connect(on_train_tile_changed)

    train.call_deferred("initialize", id, tile_pos, ori)

    # train.position = grid_service.tile_to_world(tile_pos)
    # train.current_tile = tile_pos

    trains[team].append(train)
    # Add to scene tree
    get_node("../../Containers/Trains").add_child(train)

    emit_signal("train_spawned", train)
#endregion

# #region Tile Tracking
# func _on_train_tile_changed(train: NavigationTrain, old_tile: Vector2i, new_tile: Vector2i):
#     #Here we need to check with the rail_service what will be the next orientation for the train
#     #print("Train manager: Train changed from tile %s to tile %s" % [old_tile, new_tile])
#     var delta = new_tile - old_tile
#     var new_ori = rail_service.calculate_new_orientation(new_tile, delta)
#     print("New ori: %s" % new_ori)
#     train.set_orientation(new_ori)

#     var vision_tiles: Array[Vector2i] = []
#     for offset in train_vision_offsets:
#         vision_tiles.append(new_tile + offset)
#     exploration_layer.reveal(vision_tiles)
    
# #endregion

func _process(delta: float):
    for train in trains.Player:
        train.update(delta)
    if camera_lock_to_engine:
        camera_controller.set_pos(trains.Player[0].wagons[0].position)


#region Public API
func recenter_player_train():
    #trains["Player"][0].recenter()
    camera_controller.set_pos(trains.Player[0].wagons[0].position)

func camera_lock_to_engine_toggle():
    if camera_lock_to_engine == false:
        camera_lock_to_engine = true
    else:
        camera_lock_to_engine = false

func reverse_player_train():
    trains["Player"][0].reverse_train()

func gear_toggle():
    trains["Player"][0].gear_toggle()
    
#endregion

func on_train_tile_changed(train: NavigationTrain, old_tile: Vector2i, new_tile: Vector2i) -> void:
    _check_tile_events(train, new_tile)
    
func _check_tile_events(train: NavigationTrain, new_tile: Vector2i) -> void:
	if cities_manager.is_entry_tile(new_tile):
		var city = cities_manager.get_city_by_entry_tile(new_tile)
		# print("Train reached city %s" % city.name)
		train.inmediate_stop()
		emit_signal("train_reached_city", city.name)
