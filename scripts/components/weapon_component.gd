extends Node
class_name WeaponComponent

signal fired(target_tile: Vector2i)
signal out_of_ammo

@export var damage: int = 10
@export var max_range: float = 100.0
@export var ammo: int = 10
@export var ap_cost: int = 10

signal request_bullet_fire(from, to, bullet_scene)

var BULLET_SCENE = preload("res://scenes/entities/projectiles/bullet.tscn")


func _ready():
    pass

# Public API
func shoot_at(target_tile: Vector2i, shooter_tile: Vector2i) -> void:
    # Ammo check
    if ammo <= 0:
        emit_signal("out_of_ammo")
        return
    
    # Range check
    if target_tile.distance_to(shooter_tile) > max_range:
        return

    # LOS check
    #if not los_service.has_los(shooter_tile, target_tile):
    #    return

    # Fire
    ammo -= 1
    var bullet = BULLET_SCENE.instantiate()
    emit_signal("request_bullet_fire", shooter_tile, target_tile, bullet)
    bullet.fire()

    emit_signal("fired", target_tile)
