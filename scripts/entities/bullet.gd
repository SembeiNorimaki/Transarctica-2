extends Node2D
class_name Bullet

var shooter: Node = null
var speed: float = 50.0
var damage: int = 3
var max_distance: float = 1200.0
var distance_travelled: float = 0.0

var _direction: Vector2
var _start_position: Vector2
var _has_hit := false

@onready var hitbox: HitboxComponent = $HitboxComponent

func _ready():
	hitbox.connect("hit", Callable(self, "_on_hitbox_hit"))
	hitbox.disable() # ensure no early collisions

# Public API
func fire(from: Vector2, to: Vector2):
	position = from
	_start_position = from
	_direction = (to - from).normalized()
	var _rotation = _direction.angle()
	hitbox.enable()

#Movement
func _physics_process(delta: float):
	var step = _direction * speed * delta
	position += step
	distance_travelled += step.length()
	
	if distance_travelled >= max_distance:
		queue_free()

#Hit handling
func _on_hitbox_hit(hurtbox: HurtboxComponent):
	# Ignore self-hits
	if hurtbox.get_parent() == shooter:
		#print("Ignoring self hit")
		return
	
	#Ignore if already hit something valid
	if _has_hit:
		return

	_has_hit = true
	hurtbox.take_damage(damage)

	hitbox.disable()
	queue_free()
