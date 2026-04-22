extends Node2D
class_name CameraController

signal camera_moved(global_transform: Transform2D)

@onready var cam = $Camera2D
var move_speed = 500.0
var _last_transform: Transform2D
const ZOOM_SPEED := 1.0
const MIN_ZOOM := 1.0
const MAX_ZOOM := 6.0

@onready var grid_service: GridService

@export var zoom: float = 2.0
@export var offset := Vector2.ZERO
#var offset := Vector2.ZERO

func _ready() -> void:
	cam.zoom = Vector2(zoom, zoom)
	cam.global_position = offset
	#cam.global_position = Vector2(1000, 800)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#zoom += ZOOM_SPEED
			#cam.zoom = Vector2(zoom, zoom)
			_zoom_at_screenpos(1, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#zoom -= ZOOM_SPEED
			#cam.zoom = Vector2(zoom, zoom)
			_zoom_at_screenpos(-1, event.position)

func center_at_tile(tile: Vector2i):
	var screen_pos = grid_service.tile_to_world(tile)
	cam.position = screen_pos

func set_zoom(val: float):
	zoom = val
	cam.zoom = Vector2(zoom, zoom)

func _zoom_at_screenpos(direction: int, screen_pos: Vector2):
	# 1. Convert screen → world BEFORE zoom
	var world_before = cam.get_canvas_transform().affine_inverse() * screen_pos

	# 2. Apply zoom
	zoom = clamp(zoom + direction * ZOOM_SPEED, MIN_ZOOM, MAX_ZOOM)
	cam.zoom = Vector2(zoom, zoom)

	# 3. Convert screen → world AFTER zoom
	var world_after = cam.get_canvas_transform().affine_inverse() * screen_pos

	# 4. Move camera so the point under the mouse stays fixed
	cam.position += world_before - world_after


func _process(delta: float) -> void:
	var input := Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input != Vector2.ZERO:
		input = input.normalized()
		offset += input * move_speed * delta
		cam.global_position = offset

# func _ready() -> void:
# 	_last_transform = cam.global_transform
# 	#print("CameraController ready with transform %s" % cam.global_transform)
# 	_apply_offset(Vector2(0, 0))
# 	_apply_zoom(1.0)

# func _process(delta: float) -> void:
# 	_handle_movement(delta)
	

# 	# Emit signal if camera moved
	

# func _apply_offset(offset: Vector2) -> void:
# 	cam.global_position += offset
# 	_last_transform = cam.global_transform
# 	emit_signal("camera_moved", get_viewport().canvas_transform)

# func _apply_zoom(zoom: float) -> void:
# 	cam.zoom = Vector2(zoom, zoom)
# 	emit_signal("camera_moved", get_viewport().canvas_transform)

# func _unhandled_input(event):
# 	if event is InputEventMouseButton and event.pressed:
# 		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
# 			_handle_zoom(1)
# 		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
# 			_handle_zoom(-1)
			
# func _handle_movement(delta: float) -> void:
# 	var input := Vector2.ZERO

# 	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
# 	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

# 	if input != Vector2.ZERO:
# 		input = input.normalized()
# 		_apply_offset(input * move_speed * delta)

# func _handle_zoom(direction: int) -> void:
# 	var new_zoom = cam.zoom + Vector2(direction * zoom_speed, direction * zoom_speed)
# 	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
# 	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
# 	_apply_zoom(new_zoom.x)
