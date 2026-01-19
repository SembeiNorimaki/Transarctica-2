extends Node
class_name WeaponComponent

signal fired(target_tile: Vector2i)
signal out_of_ammo


@export var damage: int = 10
@export var range: float = 100.0
@export var ammo: int = 10

var hitbox: HitboxComponent

var los_service: LOSService


func _ready():
    hitbox = get_parent().get_node("HitboxComponent")
    hitbox.connect("hit", Callable(self, "_on_hitbox_hit"))
    hitbox.disable()

# Public API
func shoot_at(target_tile: Vector2i, shooter_tile: Vector2i) -> void:
    # Ammo check
    if ammo <= 0:
        emit_signal("out_of_ammo")
        return
    
    # Range check
    if target_tile.distance_to(shooter_tile) > range:
        return

    # LOS check
    if not los_service.has_los(shooter_tile, target_tile):
        return

    # Fire
    ammo -= 1
    emit_signal("fired", target_tile)

    
# Internal: Hitbox activation (hitscan)
