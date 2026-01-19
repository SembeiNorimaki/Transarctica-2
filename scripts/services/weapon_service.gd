extends Node
class_name WeaponService

#Dependencies
@onready var los_service: LOSService
@onready var grid_service: GridService
@onready var projectiles_container: Node2D


func _ready():
	pass

# Public API
func fire_bullet(bullet_scene: PackedScene, from_tile: Vector2i, to_tile: Vector2i) -> void:
	var from_pos = grid_service.tile_to_world(from_tile)
	var to_pos = grid_service.tile_to_world(to_tile)
	print("Firing bullet from %s to %s" % [from_pos, to_pos])
	var bullet = bullet_scene.instantiate()
	projectiles_container.add_child(bullet)
	bullet.fire(from_pos, to_pos)
