extends Node
class_name TrainManager

#Injected by NavigationScene
var rail_service: RailService
var grid_service: GridService

var next_train_id = {"Player": 0, "Enemy": 0}
var teams = ["Player", "Enemy"]
var trains := {"Player": [], "Enemy": []}

var TRAIN_SCENE = preload("res://scenes/entities/units/navigation_train.tscn")

signal train_spawned(train)
signal train_tile_changed(train, old_tile, new_tile)
signal train_reached_destination(train)

func _ready() -> void:
    pass

func spawn_train(tile_pos: Vector2i, orientation: String, team: String):
    print("Spawning a train at tile %s with orientation %s" % [tile_pos, orientation])
    var id = "t%s%s" % [team[0], next_train_id[team]]
    next_train_id[team] += 1
    
    var train = TRAIN_SCENE.instantiate()

    # Dependency injection

    train.position = grid_service.tile_to_world(tile_pos)
    train.current_tile = tile_pos

    trains[team].append(train)
    # Add to scene tree
    get_node("../../Containers/Trains").add_child(train)

    emit_signal("train_spawned", train)