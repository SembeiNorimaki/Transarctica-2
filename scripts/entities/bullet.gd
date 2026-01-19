extends Node2D
class_name Bullet

var speed: float = 600.0
var damage: int = 3
var max_distance: float = 1200.0
var distance_travelled: float = 0.0
var _direction: Vector2
var _start_position: Vector2

@onready var hitbox = $HitboxComponent

func _ready():
	hitbox.connect("hit", Callable(self, "_on_hitbox_hit"))

# Public API

func fire(from: Vector2, to: Vector2):
	_direction = (to - from).normalized()
	var _rotation = _direction.angle()
	hitbox.enable()

#Movement
func _physics_process(delta: float):
	position += _direction * speed * delta
	distance_travelled += speed * delta
	if distance_travelled >= max_distance:
		queue_free()

#Hit handling
func _on_hitbox_hit(hurtbox: HurtboxComponent, dmg: int):
	hurtbox.take_damage(dmg)
	queue_free()
