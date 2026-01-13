extends Node2D
class_name CameraController

signal camera_moved(global_transform: Transform2D)

@onready var cam = $Camera2D
var move_speed = 500.0
var _last_transform: Transform2D
var zoom_speed := 1.0 
var min_zoom := 1.0 
var max_zoom := 4.0


func _ready() -> void:
	_last_transform = cam.global_transform
	print("CameraController ready with transform %s" % cam.global_transform)
	emit_signal("camera_moved",  get_viewport().canvas_transform)

func _process(delta: float) -> void:
	_handle_movement(delta)
	

	# Emit signal if camera moved
	if cam.global_transform != _last_transform:
		_last_transform = cam.global_transform
		emit_signal("camera_moved",  get_viewport().canvas_transform)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_handle_zoom(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_handle_zoom(-1)
			
func _handle_movement(delta: float) -> void:
	var input := Vector2.ZERO

	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input != Vector2.ZERO:
		input = input.normalized()
		cam.global_position += input * move_speed * delta

func _handle_zoom(direction: int) -> void:
	var new_zoom = cam.zoom + Vector2(direction * zoom_speed, direction * zoom_speed)
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	cam.zoom = new_zoom
	emit_signal("camera_moved", get_viewport().canvas_transform)
