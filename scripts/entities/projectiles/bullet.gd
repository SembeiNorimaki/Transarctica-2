extends Node2D
class_name Bullet

var shooter: Node = null
var speed: float = 200.0
var damage: int = 3
var max_distance: float = 1200.0
var distance_travelled: float = 0.0

var _direction: Vector2
var _start_position: Vector2

var _has_hit := false



@onready var combat_scene = get_parent().get_parent().get_parent()

signal bullet_hit(tile)

func _ready():
	pass

# Public API
func fire(from: Vector2, to: Vector2):
	max_distance = Vector2(from.x-to.x, from.y-to.y).length()
	print("Setting bullet max distance to ", max_distance)
	position = from
	_start_position = from
	_direction = (to - from).normalized()
	var _rotation = _direction.angle()
	

#Movement
func _physics_process(delta: float):
	var step = _direction * speed * delta
	position += step
	distance_travelled += step.length()
	
	if distance_travelled >= max_distance:
		emit_signal("bullet_hit")
		combat_scene.on_bullet_hit(position)
		queue_free()
