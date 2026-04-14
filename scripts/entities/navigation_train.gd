extends Node2D
class_name NavigationTrain

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var action_sm = $ActionStateMachine

#Labels
@onready var id_label = $Labels/IDLabel
@onready var state_label = $Labels/ActionStateLabel
@onready var gear_label = $Labels/GearLabel
@onready var speed_label = $Labels/SpeedLabel

# Dependency injection
var grid_service: GridService
var train_manager: TrainManager

var current_tile := Vector2i(-1, -1)

var id: String = ""
var team_id: String = ""
var move_speed := 0.0
var gear = "N"

const MAX_SPEED := 120.0
const ACCELERATION := 50.0
const DECELERATION := 50.0


var orientation_index := 2
var orientation: String = ORIENTATIONS[orientation_index]

var moving_forward := false
var turn_request := 0 # -1 = left, +1 = right, 0 = none

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


signal tile_changed(old_tile: Vector2i, new_tile: Vector2i)

func _ready() -> void:
	pass
	update_gear_label()
	#position = Vector2(64 * 4, 64 * 3)
	#current_tile = Vector2i(3, 1)

func initialize(id_: String, team_id_: String) -> void:
	set_id(id_)
	id_label.text = id
	set_team(team_id_)

func set_id(id_: String) -> void:
	if id == "":
		id = id_
	else:
		push_error("Unit already has an id")

func set_team(team_id_: String):
	team_id = team_id_
	if team_id == "enemy":
		sprite.modulate = Color.RED

func set_action(state: String, params = {}) -> void:
	action_sm.set_state(state, params)
	update_state_label(state)

func set_orientation(orientation_: String):
	print("Setting orientation to ", orientation_)
	orientation_index = ORIENTATIONS.find(orientation_)
	orientation = ORIENTATIONS[orientation_index]
	update_animation()

func update_state_label(state_name: String):
	state_label.text = name

func update_gear_label():
	gear_label.text = "Gear: %s" % gear
func update_speed_label():
	speed_label.text = "Speed: %s" % round(move_speed)


func inmediate_stop():
	move_speed = 0
	gear = "N"
	update_gear_label()
	update_speed_label()

func _process(delta):
	_handle_gear_toggle()
	_update_speed(delta)
	_move_train(delta)
	_check_tile_change()


	# if Input.is_action_just_pressed("ui_right"):
	#     turn_request = 1
	# elif Input.is_action_just_pressed("ui_left"):
	#     turn_request = -1

func _handle_gear_toggle():
	if Input.is_action_just_pressed("ctrl"):
		gear = "N" if gear == "D" else "D"
		update_gear_label()
	
func _update_speed(delta: float):
	if gear == "D":
		move_speed += ACCELERATION * delta
	elif gear == "N":
		move_speed -= DECELERATION * delta
	
	move_speed = clamp(move_speed, 0, MAX_SPEED)
	update_speed_label()

func _move_train(delta: float):
	var dir = get_direction_vector()
	position += dir * move_speed * delta

func _check_tile_change():
	var tile = grid_service.world_to_tile(position)
	if current_tile != tile:
		print("Navigation train changed tile")
		_on_tile_changed(current_tile, tile)
		current_tile = tile

func _on_tile_changed(from_tile: Vector2i, to_tile: Vector2i) -> void:
	train_manager.on_train_reached_tile(self, to_tile)
	
	# if turn_request == 1:
	# 	rotate_clockwise()
	# 	turn_request = 0
	# elif turn_request == -1:
	# 	rotate_counterclockwise()
	# 	turn_request = 0

	# print("Tile changed from %s to %s" % [from_tile, to_tile])
	# emit_signal("tile_changed", from_tile, to_tile)

func rotate_clockwise() -> void:
	orientation_index = (orientation_index + 1) % ORIENTATIONS.size()
	orientation = ORIENTATIONS[orientation_index]
	update_animation()

func rotate_counterclockwise() -> void:
	orientation_index = (orientation_index - 1 + ORIENTATIONS.size()) % ORIENTATIONS.size()
	orientation = ORIENTATIONS[orientation_index]
	update_animation()

func update_animation() -> void:
	print("Setting train animation to ", orientation)
	sprite.set_animation(orientation)
	sprite.play(orientation)

func on_arrived_to_tile(tile: Vector2i):
	train_manager.on_train_reached_tile(self, tile)

func get_direction_vector() -> Vector2:
	match ORIENTATIONS[orientation_index]:
		"N": return Vector2(2, -1).normalized()
		"NE": return Vector2(1, 0)
		"E": return Vector2(2, 1).normalized()
		"SE": return Vector2(0, 1)
		"S": return Vector2(-2, 1).normalized()
		"SW": return Vector2(-1, 0)
		"W": return Vector2(-2, -1).normalized()
		"NW": return Vector2(0, -1)
		_:
			return Vector2.ZERO
