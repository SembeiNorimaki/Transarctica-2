extends Node2D
class_name HorizontalTrain

#Dependencies:
var grid_service: GridService
var train_resource_container: TrainResourceContainer

# make gear an enum with values R, N, D
var gear := "N"
var speed := 0.0
var max_speed := 100.0
var acceleration := 2000.0
var deceleration := 2000.0

var wagons = []

var loading_wagon_idx: int = -1
var target_loading_wagon_idx: int = -1

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if gear == "D":
		speed = speed + acceleration * delta
	elif gear == "R":
		speed -= acceleration * delta
	elif gear == "N":
		if speed > 0:
			if wagons[target_loading_wagon_idx].global_position.x > 0:
				speed = 0
		elif speed < 0:
			if wagons[target_loading_wagon_idx].global_position.x < 0:
				speed = 0
			
			
		# if speed > 0:
		# 	speed -= deceleration * delta
		# 	if speed < 0:
		# 		speed = 0
		# 		_on_train_just_stopped()
		# elif speed < 0:
		# 	speed += deceleration * delta
		# 	if speed > 0:
		# 		speed = 0
		# 		_on_train_just_stopped()

	speed = clamp(speed, -max_speed, max_speed)

	position.x += speed * delta


# when train just stops, calculate what is the loading wagon
func _on_train_just_stopped():
	for i in range(wagons.size()):
		if abs(wagons[i].global_position.x) < 50:
			loading_wagon_idx = i
			print("Loading wagon idx: %s" % loading_wagon_idx)
			return
	loading_wagon_idx = -1
	print("Loading wagon idx: %s" % loading_wagon_idx)
	

func calculate_target_loading_wagon_idx():
	if speed > 0:
		# we look for the first wagon with negative x position
		for i in range(wagons.size()):
			if wagons[i].global_position.x < 0:
				target_loading_wagon_idx = i
				return
		target_loading_wagon_idx = -1
	elif speed < 0:
		# we look for the first wagon with negative x position
		for i in range(wagons.size() - 1, 0, -1):
			if wagons[i].global_position.x > 0:
				target_loading_wagon_idx = i
				return
		target_loading_wagon_idx = -1


func add_wagon(wagon_data: Dictionary):
	var wagon_name = wagon_data.wagon_name
	var wagon_info = WagonTypes.TYPES[wagon_name]

	var wagon = wagon_info.scene.instantiate()

	var cargo = wagon_data.cargo
	var resource_name = ""
	var resource_qty = 0
	if cargo:
		resource_name = cargo[0].resource_name
		resource_qty = cargo[0].resource_qty


	wagon.call_deferred("set_resource_type", resource_name)
	wagon.call_deferred("set_resource_qty", resource_qty)

	train_resource_container.add_wagon(wagon_name, resource_name, resource_qty)

	# Dependecy injection
	wagon.grid_service = grid_service


	# Position the wagon at the end of the train
	var wagon_pos = position
	if wagons:
		var prev_wagon_name = wagons[-1].get_script().get_global_name()
		wagon_pos = wagons[-1].position
		wagon_pos.x -= WagonTypes.TYPES[prev_wagon_name].size.x / 2
		wagon_pos.x -= WagonTypes.TYPES[wagon_name].size.x / 2
		wagon_pos.x -= 2

	wagon.position = wagon_pos

	add_child(wagon)
	wagons.append(wagon)
	

func set_wagon_resource_type(wagon_idx: int, resource_name: String):
	wagons[wagon_idx].set_resource_type(resource_name)

func set_wagon_resource_qty(wagon_idx: int, qty: int):
	wagons[wagon_idx].set_resource_qty(qty)
	

func gear_up():
	if gear == "R":
		gear = "N"
		calculate_target_loading_wagon_idx()
	elif gear == "N":
		gear = "D"
	

func gear_down():
	if gear == "D":
		gear = "N"
		calculate_target_loading_wagon_idx()
	elif gear == "N":
		gear = "R"


func check_wagon_click(mouse_pos: Vector2) -> int:
	for i in range(wagons.size()):
		if wagons[i].check_click(mouse_pos):
			return i
	return -1
