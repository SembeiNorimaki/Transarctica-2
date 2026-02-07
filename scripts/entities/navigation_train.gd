extends Node2D
class_name NavigationTrain

# Dependency injection
var grid_service: GridService


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


var speed := 100.0
var orientation_index := 2
var orientation: String = ORIENTATIONS[orientation_index]
var current_tile := Vector2i(-1, -1)
var moving_forward := false
var turn_request := 0 # -1 = left, +1 = right, 0 = none

signal tile_changed(old_tile: Vector2i, new_tile: Vector2i)

func _ready() -> void:
	position = Vector2(64, 96)
	current_tile = Vector2i(1, 1)

func _process(delta):
	var tile = grid_service.world_to_tile(position)
	if tile != current_tile:
		_on_tile_changed(current_tile, tile)
		current_tile = tile

	if moving_forward:
		move_forward(delta)

	if Input.is_action_pressed("ui_up"):
		moving_forward = true
	elif Input.is_action_pressed("ui_down"):
		moving_forward = false
		
	elif Input.is_action_just_pressed("ui_right"):
		turn_request = 1
	elif Input.is_action_just_pressed("ui_left"):
		turn_request = -1

func _on_tile_changed(from_tile: Vector2i, to_tile: Vector2i) -> void:
	if turn_request == 1:
		rotate_clockwise()
		turn_request = 0
	elif turn_request == -1:
		rotate_counterclockwise()
		turn_request = 0

	print("Tile changed from %s to %s" % [from_tile, to_tile])
	emit_signal("tile_changed", from_tile, to_tile)

func rotate_clockwise() -> void:
	orientation_index = (orientation_index + 1) % ORIENTATIONS.size()
	orientation = ORIENTATIONS[orientation_index]
	update_animation()

func rotate_counterclockwise() -> void:
	orientation_index = (orientation_index - 1 + ORIENTATIONS.size()) % ORIENTATIONS.size()
	orientation = ORIENTATIONS[orientation_index]
	update_animation()

func update_animation() -> void:
	var sprite = $AnimatedSprite2D
	sprite.set_animation(orientation)
	sprite.play(orientation)


func move_forward(delta):
	var dir = get_direction_vector()
	position += dir * speed * delta

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
