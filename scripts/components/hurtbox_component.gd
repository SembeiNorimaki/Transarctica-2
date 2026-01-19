extends Area2D
class_name HurtboxComponent

signal died

@export var health: int = 100
var health_component: HealthComponent

func _ready():
    health_component = get_parent().get_node("HealthComponent")

func take_damage(amount: int):
    health -= amount
    if health <= 0:
        emit_signal("died")
