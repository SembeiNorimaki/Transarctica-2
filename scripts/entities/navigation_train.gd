extends Node2D
class_name NavigationTrain

@onready var action_sm = $ActionStateMachine

# Labels
@onready var id_label = $Labels/IDLabel
@onready var state_label = $Labels/ActionStateLabel
@onready var gear_label = $Labels/GearLabel
@onready var speed_label = $Labels/SpeedLabel

# Conatiners
@onready var wagon_container = $WagonContainer


# Dependency injection
var grid_service: GridService
var train_manager: NavigationTrainManager
var rail_service: RailService


var id: String = ""
var team_id: String = ""
var move_speed := 0.0
var gear = "N"


const MAX_SPEED := 120.0
const ACCELERATION := 50.0
const DECELERATION := 50.0


#var current_tile := Vector2i(-1, -1)
#var orientation_index := 2
#var orientation: String = ORIENTATIONS[orientation_index]

#var moving_forward := false
#var turn_request := 0 # -1 = left, +1 = right, 0 = none


var wagons = []

const ORIENTATIONS = [
	"N",
	"NE",
	"E",
	"SE",
	"S",
	"SW",
	"W",
    "NW"
]

const OPPOSITE_ORIENTATION = {
	"N": "S",
	"NE": "SW",
	"E": "W",
	"SE": "NW",
	"S": "N",
	"SW": "NE",
	"W": "E",
	"NW": "SE"
}

var ori_to_heading = {
	"N": Vector2(2, -1).normalized(),
	"NE": Vector2(1, 0),
	"E": Vector2(2, 1).normalized(),
	"SE": Vector2(0, 1),
	"S": Vector2(-2, 1).normalized(),
	"SW": Vector2(-1, 0),
	"W": Vector2(-2, -1).normalized(),
	"NW": Vector2(0, -1)
}

const WAGON_SCENE = preload("res://scenes/entities/trains/navigation_wagon.tscn")
const LOCOMOTIVE_SCENE = preload("res://scenes/entities/trains/navigation_locomotive.tscn")

signal train_tile_changed(navigation_train: NavigationTrain, old_tile: Vector2i, new_tile: Vector2i)

func _ready() -> void:
	add_locomotive()
	add_wagon()
	add_wagon()
	add_wagon()
	#update_gear_label()
	#position = Vector2(64 * 4, 64 * 3)
	#current_tile = Vector2i(3, 1)

#region initialization
func initialize(tile_pos_: Vector2i, ori_: String) -> void:
	initialize_wagon_positions(tile_pos_, ori_)
	#set_id(id_)
	#id_label.text = id
	#set_team(team_id_)

func initialize_wagon_positions(tile_pos_: Vector2i, ori_: String):
	var offset = Vector2(-32, -16)
	var current_pos = grid_service.tile_to_world(tile_pos_)
	for wagon in wagons:
		wagon.set_pos(current_pos)
		wagon.set_orientation(ori_)
		wagon.set_heading(ori_to_heading[ori_])
		current_pos += offset

func add_locomotive():
	var locomotive = LOCOMOTIVE_SCENE.instantiate()
	
	# dependency injection
	locomotive.grid_service = grid_service
	
	# connect signals
	locomotive.tile_changed.connect(_on_locomotive_tile_changed)

	# add to container
	wagon_container.add_child(locomotive)
	wagon_container.move_child(locomotive, 0)

	wagons.append(locomotive)

func add_wagon():
	var wagon = WAGON_SCENE.instantiate()
	
	# dependency injection
	wagon.grid_service = grid_service

	# connect signals
	wagon.tile_changed.connect(_on_wagon_tile_changed)


	# add to container
	wagon_container.add_child(wagon, false)
	wagon_container.move_child(wagon, 0)

	wagons.append(wagon)

#endregion

func set_id(id_: String) -> void:
	if id == "":
		id = id_
	else:
		push_error("Unit already has an id")

func set_team(team_id_: String):
	team_id = team_id_
	#if team_id == "enemy":
	#	sprite.modulate = Color.RED

func set_action(state: String, params = {}) -> void:
	action_sm.set_state(state, params)
	update_state_label(state)

func update_state_label(state_name: String):
	state_label.text = name

func update_gear_label():
	gear_label.text = "Gear: %s" % gear

func update_speed_label():
	speed_label.text = "Speed: %s" % round(move_speed)


func _process(delta):	
	_update_speed(delta)
	#_move_train(delta)
	#_check_tile_change()


	# if Input.is_action_just_pressed("ui_right"):
	#     turn_request = 1
	# elif Input.is_action_just_pressed("ui_left"):
	#     turn_request = -1


func gear_toggle():
	gear = "N" if gear == "D" else "D"
	update_gear_label()

func reverse_train():
	var positions = []
	var orientations = []
	var n = wagons.size()
	for wagon in wagons:
		positions.append(wagon.position)
		orientations.append(wagon.orientation)
	for i in range(n):
		wagons[n-i-1].set_pos(positions[i])
		wagons[n-i-1].set_orientation(OPPOSITE_ORIENTATION[orientations[i]])
		wagons[n-i-1].set_heading(ori_to_heading[OPPOSITE_ORIENTATION[orientations[i]]])

func inmediate_stop():
	move_speed = 0
	gear = "N"
	update_gear_label()
	update_speed_label()
	for wagon in wagons:
		wagon.speed = move_speed

func _update_speed(delta: float):
	if gear == "D":
		move_speed += ACCELERATION * delta
	elif gear == "N":
		move_speed -= DECELERATION * delta
	
	move_speed = clamp(move_speed, 0, MAX_SPEED)
	for wagon in wagons:
		wagon.speed = move_speed
	update_speed_label()



func _on_locomotive_tile_changed(locomotive, old_tile: Vector2i, new_tile: Vector2i):
	print("*** Locomotive has changed tile")
	_handle_tile_change(locomotive, old_tile, new_tile)

	# locomotive should also handle explaration
	#var vision_tiles: Array[Vector2i] = []
	#for offset in train_vision_offsets:
	#	vision_tiles.append(new_tile + offset)
	#exploration_layer.reveal(vision_tiles)

	# locomotive should also check for events
	train_tile_changed.emit(self, old_tile, new_tile)

func _on_wagon_tile_changed(wagon, old_tile: Vector2i, new_tile: Vector2i):
	print("*** Wagon has changed tile")
	_handle_tile_change(wagon, old_tile, new_tile)

func _handle_tile_change(wagon, old_tile: Vector2i, new_tile: Vector2i):
	# Here we need to check with the rail_service what will be the next orientation for the wagon
	var delta = new_tile - old_tile
	var new_ori = rail_service.calculate_new_orientation(new_tile, delta)
	wagon.set_orientation(new_ori)
	wagon.set_heading(ori_to_heading[new_ori])
	
	





# func on_arrived_to_tile(tile: Vector2i):
# 	train_manager.on_train_reached_tile(self , tile)




# # !!!
# func _move_train(delta: float):
# 	var dir = get_direction_vector()
# 	position += dir * move_speed * delta

# func recenter():
# 	position = grid_service.tile_to_world(current_tile)
	

# func _check_tile_change():
# 	var tile = grid_service.world_to_tile(position)
# 	if current_tile != tile:
# 		print("Navigation train changed tile")
# 		_on_tile_changed(current_tile, tile)
# 		current_tile = tile

# !!!
# func _on_tile_changed(from_tile: Vector2i, to_tile: Vector2i) -> void:
# 	train_manager.on_train_reached_tile(self , to_tile)
	
	# if turn_request == 1:
	# 	rotate_clockwise()
	# 	turn_request = 0
	# elif turn_request == -1:
	# 	rotate_counterclockwise()
	# 	turn_request = 0

	# print("Tile changed from %s to %s" % [from_tile, to_tile])
	# emit_signal("tile_changed", from_tile, to_tile)

# func rotate_clockwise() -> void:
# 	orientation_index = (orientation_index + 1) % ORIENTATIONS.size()
# 	orientation = ORIENTATIONS[orientation_index]
# 	update_animation()

# func rotate_counterclockwise() -> void:
# 	orientation_index = (orientation_index - 1 + ORIENTATIONS.size()) % ORIENTATIONS.size()
# 	orientation = ORIENTATIONS[orientation_index]
# 	update_animation()

# func update_animation() -> void:
# 	print("Setting train animation to ", orientation)
# 	sprite.set_animation(orientation)
# 	sprite.play(orientation)



# func get_direction_vector() -> Vector2:
# 	match ORIENTATIONS[orientation_index]:
# 		"N": return Vector2(2, -1).normalized()
# 		"NE": return Vector2(1, 0)
# 		"E": return Vector2(2, 1).normalized()
# 		"SE": return Vector2(0, 1)
# 		"S": return Vector2(-2, 1).normalized()
# 		"SW": return Vector2(-1, 0)
# 		"W": return Vector2(-2, -1).normalized()
# 		"NW": return Vector2(0, -1)
# 		_:
# 			return Vector2.ZERO
