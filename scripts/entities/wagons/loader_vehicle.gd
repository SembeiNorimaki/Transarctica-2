extends Node2D
class_name LoaderVehicle

# Dependency injection
var camera_controller: CameraController
var horizontal_train: HorizontalTrain

@onready var cargo_sprite = $CargoSprite
var speed := 0.0
var max_speed := 300.0
var acceleration := 100.0
var deceleration := 300.0
var gear := "N"
var cargo := ""

var resource_name_to_frame = {
	"alcohol": 0,
	"antiques": 1,
	"missiles": 2,
	"bricks": 3,
	"caviar": 4,
	"oil": 5,
	"earth": 6,
	"coal": 7,
	"plants": 8,
	"copper": 9,
	"dung": 10,
	"rails": 11,
	"fish": 12,
	"rods": 13,
	"salt": 14,
	"furs": 15,
	"gasoline": 16,
	"inspection": 17,
	"gray": 18,
	"meat": 19,
	"wood": 20
}
var frame_to_resource_name = {
	0: "alcohol",
	1: "antiques",
	2: "missiles",
	3: "bricks",
	4: "caviar",
	5: "oil",
	6: "earth",
	7: "coal",
	8: "plants",
	9: "copper",
	10: "dung",
	11: "rails",
	12: "fish",
	13: "rods",
	14: "salt",
	15: "furs",
	16: "gasoline",
	17: "inspection",
	18: "gray",
	19: "meat",
	20: "wood"
}

func gear_up():
	if gear == "R":
		gear = "N"
	elif gear == "N":
		gear = "D"
	

func gear_down():
	if gear == "D":
		gear = "N"
	elif gear == "N":
		gear = "R"

func unload() -> String:
	if cargo == "":
		print("Error, loader is empty")
		return ""
	var result: String = cargo
	cargo = ""
	cargo_sprite.visible = false
	return result
	

func is_empty() -> bool:
	return cargo == ""

func get_cargo_type() -> String:
	return cargo

func load(resource_name: String):
	cargo = resource_name
	cargo_sprite.frame = resource_name_to_frame[resource_name]
	cargo_sprite.visible = true

func _process(delta: float) -> void:
	if gear == "D":
		speed = speed + acceleration * delta
	elif gear == "R":
		speed -= acceleration * delta
	elif gear == "N":
		if speed > 0.0:
			speed -= deceleration * delta
			if speed < 0.0:
				speed = 0.0
		elif speed < 0:
			speed += deceleration * delta
			if speed > 0.0:
				speed = 0.0
	
	position.x += speed * delta

	camera_controller.set_pos(position + Vector2(0, 200))
