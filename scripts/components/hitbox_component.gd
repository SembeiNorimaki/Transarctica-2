extends Area2D
class_name HitboxComponent

signal hit(hurtbox: HurtboxComponent)

func _ready():
    monitoring = false
    monitorable = false
    area_entered.connect(_on_area_entered, CONNECT_DEFERRED)

func _on_area_entered(area: Area2D):
    if area is HurtboxComponent:
        emit_signal("hit", area)

func enable():
    monitoring = true
    monitorable = true

func disable():
    monitoring = false
    monitorable = false
