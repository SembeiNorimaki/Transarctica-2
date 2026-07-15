extends Projectile
class_name Ballistic

var _from_pos: Vector2
var _to_pos: Vector2
var _duration: float = 1.5   # seconds of flight
var _elapsed: float = 0.0
var _arc_height: float = 60.0  # pixels at arc peak


func _ready():
	pass


# Public API
# arc_height: how high the arc reaches in pixels (world space)
# duration:   how many seconds the flight takes
func fire(from: Vector2, to: Vector2, arc_height: float = 60.0, duration: float = 1.5) -> void:
	_from_pos = from
	_to_pos = to
	_arc_height = arc_height
	_duration = duration
	_elapsed = 0.0
	position = from


func _physics_process(delta: float) -> void:
	_elapsed += delta
	var t = clampf(_elapsed / _duration, 0.0, 1.0)

	# Parabolic arc: lerp x/y linearly, subtract a sine bump for the arc
	position = Vector2(
		lerpf(_from_pos.x, _to_pos.x, t),
		lerpf(_from_pos.y, _to_pos.y, t) - _arc_height * sin(PI * t)
	)

	if t >= 1.0:
		_on_hit(_to_pos)
		queue_free()
