extends Node
class_name WeaponService

#Dependencies
@onready var los_service: LOSService
@onready var grid_service: GridService
@onready var projectiles_container: Node2D

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
    bullet.position = from_pos
    bullet.damage = weapon_component.damage
    projectiles_container.add_child(bullet)
    bullet.fire(from_pos, to_pos)
    AudioService.play_sfx(SHOOT_SFX)
    return bullet
