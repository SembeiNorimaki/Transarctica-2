extends Node2D

# THIS COMPONENT HOLD LOGIC FOR TRADING IN THE TRADE SCENE
# TANK BASE HOLDS MINIMAL LOGIC RELATED TO TRADE SCENE IN CASE 
# OF FUTURE USE CASE FOR OMNIDIRECITONAL VEHICLE

# Dependency injection
var camera_controller: CameraController
var horizontal_train: HorizontalTrain

@onready var cargo_sprite = $CargoSprite
@onready var crate = $CrateSprite

# Movement variables
var speed := 0.0
var max_speed := 300.0
var acceleration := 100.0
var deceleration := 300.0
var gear := "N"

# Cargo variables
var cargo := ""
var crate_qty := 0

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
	"mammothdung": 10,
	"rails": 11,
	"fish": 12,
	"fishingrods": 13,
	"salt": 14,
	"furs": 15,
	"gasoline": 16,
	"inspection": 17,
	"gray": 18,
	"wolfmeat": 19,
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
	10: "mammothdung",
	11: "rails",
	12: "fish",
	13: "fishingrods",
	14: "salt",
	15: "furs",
	16: "gasoline",
	17: "inspection",
	18: "gray",
	19: "wolfmeat",
	20: "wood"
}

func initialize():
	crate_qty = 0
	crate.set_mode("InWagon")
	crate.set_qty(crate_qty)
	get_parent().get_parent().sprite.scale = Vector2(0.5,0.5)
	scale = Vector2(2,2)

# func unload() -> String:
# 	if cargo == "":
# 		print("Error, loader is empty")
# 		return ""
# 	var result: String = cargo
# 	cargo = ""
# 	cargo_sprite.visible = false
# 	return result

func is_empty() -> bool:
	return cargo == ""

func get_cargo_type() -> String:
	return cargo

func get_qty() -> int:
	return crate_qty

# func load(resource_name: String):
# 	cargo = resource_name
# 	cargo_sprite.frame = resource_name_to_frame[resource_name]
# 	cargo_sprite.visible = true

func load_crate(resource_name: String):
	print("Loading crate")
	cargo = resource_name
	cargo_sprite.frame = resource_name_to_frame[resource_name]
	cargo_sprite.visible = true
	crate_qty += 1
	crate.set_qty(crate_qty)

func unload_crate() -> String:
	print("Unloading crate")
	crate_qty -= 1
	crate.set_qty(crate_qty)
	if crate_qty == 0:
		cargo = ""
		cargo_sprite.visible = false
	return cargo
	
func set_crate_qty(qty: int):
	crate_qty = qty
	crate.set_qty(crate_qty)
	if crate_qty == 0:
		cargo = ""
		cargo_sprite.visible = false

#func _process(delta: float) -> void:
	#if gear == "D":
		#speed = speed + acceleration * delta
	#elif gear == "R":
		#speed -= acceleration * delta
	#elif gear == "N":
		#if speed > 0.0:
			#speed -= deceleration * delta
			#if speed < 0.0:
				#speed = 0.0
		#elif speed < 0:
			#speed += deceleration * delta
			#if speed > 0.0:
				#speed = 0.0
	#
	#position.x += speed * delta

	#camera_controller.set_pos(position + Vector2(0, 380)) # for fullscreen
	camera_controller.set_pos(position + Vector2(0, 200)) # for windowed mode
