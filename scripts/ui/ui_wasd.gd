extends Node
class_name UI_WASD

signal move_vector_changed(vec: Vector2i)
signal aim_pressed()
signal aim_released()

var prev_vec := Vector2i.ZERO

func _process(delta):
	var x = int(Input.is_action_pressed("d")) - int(Input.is_action_pressed("a"))
	var y = int(Input.is_action_pressed("s")) - int(Input.is_action_pressed("w"))

	var vec = Vector2i(x, y)
	if vec != prev_vec:
		prev_vec = vec
		# if vec != Vector2.ZERO:
		# 	vec = vec.normalized()
		emit_signal("move_vector_changed", vec)
		

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			emit_signal("aim_pressed")
		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			emit_signal("aim_released")
