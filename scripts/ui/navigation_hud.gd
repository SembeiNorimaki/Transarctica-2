extends Node2D

@export var hud_offset: Vector2 = Vector2.ZERO 

@onready var cam = get_viewport().get_camera_2d()
@onready var aspect = $AspectRatioContainer

var starting_position: Vector2 = Vector2(77,0) # MUST BE AT POSITION (77,0) OR SCALING WILL BREAK

func _process(delta: float) -> void:
	var cam = get_viewport().get_camera_2d()

	
	# ALIGN HUD TO VIEWPORT
	var canvas_transform = get_viewport().get_canvas_transform()
	var viewport_origin = -canvas_transform.origin
	#global_position = viewport_origin + Vector2(0, 0)

	if cam:
		scale = Vector2(1/cam.zoom.x, 1/cam.zoom.y)
		global_position = cam.position + hud_offset
	
	# UPDATE DISPLAY NUMBERS
	update_info()

func update_info():
	$HUDElements/Interactables/N/Label.text = "Null"
	$HUDElements/Interactables/Gold/Label.text = str(GameState.state.money)
	$HUDElements/Interactables/Fuel/Label.text = "Null"
	$HUDElements/Interactables/Speed/Label.text = "Null"
	$TimeLabel.text = "Null"
	
