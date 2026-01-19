extends Area2D
class_name HitboxComponent

signal hit(hurtbox: HurtboxComponent, damage: int)

func _ready():
    monitoring = false
    connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D):
    if area is HurtboxComponent:
        emit_signal("hit", area, 10)

func enable():
    monitoring = true

func disable():
    monitoring = false
