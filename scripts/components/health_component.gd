extends Node
class_name HealthComponent

signal died
signal health_changed(current, max)

@export var max_health: int = 100
var current_health: int
var is_dead := false

func _ready():
    current_health = max_health

func take_damage(amount: int):
    if is_dead:
        return
    current_health = max(0, current_health - amount)
    emit_signal("health_changed", current_health, max_health)
    if current_health == 0:
        is_dead = true
        emit_signal("died")
