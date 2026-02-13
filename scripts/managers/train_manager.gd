extends Node
class_name TrainManager

#Injected by NavigationScene
var rail_service: RailService
var grid_service: GridService
var cities_manager: CitiesManager

var next_train_id = {"Player": 0, "Enemy": 0}
var teams = ["Player", "Enemy"]
var trains := {"Player": [], "Enemy": []}

var TRAIN_SCENE = preload("res://scenes/entities/units/navigation_train.tscn")

signal train_spawned(train)
signal train_tile_changed(train, old_tile, new_tile)
signal train_reached_destination(train)

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
	#print("New ori: %s" % new_ori)
	train.set_orientation(new_ori)
	
#endregion

#region Public API

#endregion

func on_train_reached_tile(train: NavigationTrain, tile: Vector2i) -> void:
	_on_train_tile_changed(train, train.current_tile, tile)
	train.current_tile = tile
	_check_tile_events(train, tile)
	#_give_next_tile(unit)

func _check_tile_events(train: NavigationTrain, tile: Vector2i) -> void:
	if cities_manager.is_entry_tile(tile):
		var city = cities_manager.get_city_by_entry_tile(tile)
		#print("Train reached city %s" % city.name)
		train.inmediate_stop()