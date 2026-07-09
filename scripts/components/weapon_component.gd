extends Node
class_name WeaponComponent

signal fired(target_tile: Vector2i)
signal out_of_ammo

var damage: int
var max_range: float
var ammo: int
var ap_cost: int
var accuracy: int

var weapon_type := ""

signal request_bullet_fire(from, to, bullet_scene)

var BULLET_SCENE = preload("res://scenes/entities/projectiles/bullet.tscn")


func _ready():
    pass


func set_type(weapon_type_: String) -> void:
    weapon_type = weapon_type_
    var weapon_data = WeaponDatabase.get_weapon_data(weapon_type)
    damage = weapon_data.damage
    accuracy = weapon_data.accuracy
    max_range = weapon_data.range
    ammo = weapon_data.ammo
    ap_cost = weapon_data.ap_cost
    

func get_type() -> String:
    return weapon_type

# Public API
# func shoot_at(target_tile: Vector2i, shooter_tile: Vector2i) -> void:
#     # Ammo check
#     if ammo <= 0:
#         emit_signal("out_of_ammo")
#         return
    
#     # Range check
#     if target_tile.distance_to(shooter_tile) > max_range:
#         return

#     # LOS check
#     #if not los_service.has_los(shooter_tile, target_tile):
#     #    return

#     # Fire
#     ammo -= 1
#     var bullet = BULLET_SCENE.instantiate()
#     emit_signal("request_bullet_fire", shooter_tile, target_tile, bullet)
#     bullet.fire()

#     emit_signal("fired", target_tile)
