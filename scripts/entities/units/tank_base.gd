extends Node2D

# TANK BASE HOLDS MINIMAL LOGIC RELATED TO TRADE SCENE IN CASE 
# OF FUTURE USE CASE FOR OMNIDIRECITONAL VEHICLE
# LOADER COMPONENT HOLDS MOST LOGIC FOR TRADING IN THE TRADE SCENE

@onready var ui_wasd = $UI_WASD
@onready var sprite = $Sprite2D
@onready var loader_component = $Sprite2D/LoaderComponent

var angle = 0.0 # angle 0 measn N, increases counter-clockwise
var speed = 0.0
var rotation_speed = 1.0
var max_speed = 100.0
var acceleration = 1.0
var deceleration = 5.0
var heading = Vector2.UP

var vec := Vector2i.ZERO

func _ready():
	ui_wasd.move_vector_changed.connect(_on_move_vector_changed)
	
func _process(delta):
	if vec.y == -1:
		speed += acceleration
		if speed > max_speed:
			speed = max_speed
	if vec.x == 1:
		angle += rotation_speed
	if angle < 0:
		angle += 360
	if vec.x == -1:
		angle -= rotation_speed
	if angle > 360:
		angle -= 360
	if vec.y == 0:
		speed -= deceleration
		if speed < 0:
			speed = 0

	heading = Vector2.UP.rotated(deg_to_rad(angle))
	sprite.frame = int((360 - angle) / 12)

	position += heading * speed * delta
	#print(position)
	
	# LIVE DEBUGGING  
	$Sprite2D/DebugLabel.text = str(angle) + " " + str(sprite.frame)


func _on_move_vector_changed(v: Vector2i):
	vec = v
