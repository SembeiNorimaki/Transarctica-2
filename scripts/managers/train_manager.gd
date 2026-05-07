extends Node
class_name TrainManager

#Injected by NavigationScene
var rail_service: RailService
var grid_service: GridService
var cities_manager: CitiesManager

var exploration_layer

var next_train_id = {"Player": 0, "Enemy": 0}
var teams = ["Player", "Enemy"]
var trains := {"Player": [], "Enemy": []}

var TRAIN_SCENE = preload("res://scenes/entities/units/navigation_train.tscn")

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
func spawn_train(tile_pos: Vector2i, orientation: String, team: String):
	#print("Spawning a train at tile %s with orientation %s" % [tile_pos, orientation])
	var id = "t%s%s" % [team[0], next_train_id[team]]
	next_train_id[team] += 1
	
	var train = TRAIN_SCENE.instantiate()

	# Dependency injection
	train.train_manager = self
	train.grid_service = grid_service

	train.position = grid_service.tile_to_world(tile_pos)
	train.current_tile = tile_pos

	trains[team].append(train)
	# Add to scene tree
	get_node("../../Containers/Trains").add_child(train)

	emit_signal("train_spawned", train)
#endregion

#region Tile Tracking
func _on_train_tile_changed(train: NavigationTrain, old_tile: Vector2i, new_tile: Vector2i):
	#Here we need to check with the rail_service what will be the next orientation for the train
	#print("Train manager: Train changed from tile %s to tile %s" % [old_tile, new_tile])
	var delta = new_tile - old_tile
	var new_ori = rail_service.calculate_new_orientation(new_tile, delta)
	print("New ori: %s" % new_ori)
	train.set_orientation(new_ori)

	var vision_tiles: Array[Vector2i] = []
	for offset in train_vision_offsets:
		vision_tiles.append(new_tile + offset)
	exploration_layer.reveal(vision_tiles)
	
#endregion

#region Public API
func recenter_player_train():
	trains["Player"][0].recenter()
func reverse_player_train_direction():
	trains["Player"][0].reverse_direction()
#endregion

func on_train_reached_tile(train: NavigationTrain, tile: Vector2i) -> void:
	_on_train_tile_changed(train, train.current_tile, tile)
	train.current_tile = tile
	_check_tile_events(train, tile)
	#_give_next_tile(unit)

func _check_tile_events(train: NavigationTrain, tile: Vector2i) -> void:
	if cities_manager.is_entry_tile(tile):
		var city = cities_manager.get_city_by_entry_tile(tile)
		print("Train reached city %s" % city.name)
		train.inmediate_stop()
		emit_signal("train_reached_city", city.name)
