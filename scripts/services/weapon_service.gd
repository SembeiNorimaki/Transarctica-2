extends Node
class_name WeaponService

#Dependencies
var los_service: LOSService
var grid_service: GridService
var edge_occupancy_service: EdgeOccupancyService
var projectiles_container: Node2D

const SHOOT_SFX: AudioStream = preload("res://assets/audio/AK47.wav")

# This system should:
#     spawns bullets
#     plays muzzle flash
#     plays sound
#     applies recoil
#     handles projectile movement


func _ready():
	pass


# Public API
func fire_bullet(bullet_scene: PackedScene, from_tile: Vector2i, to_tile: Vector2i, shooter: Unit) -> Bullet:
	var from_pos = grid_service.tile_to_world(from_tile)
	var to_pos = grid_service.tile_to_world(to_tile)
	var weapon_component = shooter.weapon

	var bullet = bullet_scene.instantiate()
	bullet.grid_service = grid_service
	bullet.edge_occupancy_service = edge_occupancy_service
	bullet.position = from_pos
	bullet.damage = weapon_component.damage
	projectiles_container.add_child(bullet)
	bullet.fire(from_pos, to_pos)
	AudioService.play_sfx(SHOOT_SFX)
	return bullet


func fire_ballistic(ballistic_scene: PackedScene, from_tile: Vector2i, to_tile: Vector2i,
		shooter: Unit, arc_height: float = 60.0, duration: float = 1.5) -> Ballistic:
	var from_pos = grid_service.tile_to_world(from_tile)
	var to_pos   = grid_service.tile_to_world(to_tile)
	var weapon_component = shooter.weapon

	var ballistic = ballistic_scene.instantiate()
	ballistic.grid_service = grid_service
	ballistic.edge_occupancy_service = edge_occupancy_service
	ballistic.damage = weapon_component.damage
	projectiles_container.add_child(ballistic)
	ballistic.fire(from_pos, to_pos, arc_height, duration)
	return ballistic
