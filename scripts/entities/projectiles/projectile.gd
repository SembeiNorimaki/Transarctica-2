extends Node2D
class_name Projectile

# Injected by WeaponService
var grid_service: GridService
var edge_occupancy_service: EdgeOccupancyService
var shooter: Node = null

# Hit payload
var damage: int = 3
var is_explosive: bool = false
var explosion_radius: int = 1  # in tiles

@onready var combat_scene = get_parent().get_parent().get_parent()

signal projectile_hit


# Called by subclasses when the projectile reaches its destination or hits an obstacle.
func _on_hit(world_pos: Vector2) -> void:
	emit_signal("projectile_hit")
	if is_explosive:
		combat_scene.on_explosion(world_pos, explosion_radius, damage)
	else:
		combat_scene.on_bullet_hit(world_pos, damage)
