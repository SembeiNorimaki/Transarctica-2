extends Node2D
class_name CameraController

signal camera_moved(global_transform: Transform2D)

@onready var cam = $Camera2D
var move_speed = 500.0
var _last_transform: Transform2D


func _ready() -> void:
    _last_transform = cam.global_transform
    print("CameraController ready with transform %s" % cam.global_transform)
    emit_signal("camera_moved", cam.global_transform)

func _process(delta: float) -> void:
    _handle_movement(delta)
    _handle_zoom()

    # Emit signal if camera moved
    if cam.global_transform != _last_transform:
        _last_transform = cam.global_transform
        emit_signal("camera_moved", cam.global_transform)

func _handle_movement(delta: float) -> void:
    var input := Vector2.ZERO

    input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

    if input != Vector2.ZERO:
        input = input.normalized()
        cam.global_position += input * move_speed * delta

func _handle_zoom() -> void:
    pass
