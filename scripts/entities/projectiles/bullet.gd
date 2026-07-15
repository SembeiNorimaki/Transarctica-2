extends Projectile
class_name Bullet

var speed: float = 200.0
var max_distance: float = 1200.0
var distance_travelled: float = 0.0

var _direction: Vector2
var _start_position: Vector2
var _current_tile: Vector2i

var _has_hit := false


func _ready():
	pass


# Public API
func fire(from: Vector2, to: Vector2):
	max_distance = Vector2(from.x - to.x, from.y - to.y).length()
	# print("Setting bullet max distance to ", max_distance)
	position = from
	_start_position = from
	_direction = (to - from).normalized()
	var _rotation = _direction.angle()
	_current_tile = grid_service.world_to_tile(from)


#Movement
func _physics_process(delta: float):
	var step = _direction * speed * delta
	position += step
	distance_travelled += step.length()

	# Tile-crossing wall check
	var new_tile = grid_service.world_to_tile(position)
	if new_tile != _current_tile:
		var edge = edge_occupancy_service.get_edge(_current_tile, new_tile)
		if edge != null and edge.edge_type == Edge.EdgeType.WALL:
			combat_scene.on_bullet_hit_wall_edge(_current_tile, new_tile, damage)
			queue_free()
			return
		_current_tile = new_tile

	if distance_travelled >= max_distance:
		_on_hit(position)
		queue_free()
