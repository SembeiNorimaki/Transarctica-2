extends Area2D
class_name HurtboxComponent

signal died

@export var health: int = 100
var health_component: HealthComponent

func _ready():
    health_component = get_parent().get_node("HealthComponent")
    health_component.connect("died", Callable(self, "_on_died"))

func take_damage(amount: int):
    #print("HurtboxComponent take_damage %s" % amount)
    health_component.take_damage(amount)

    # health = max(health - amount, 0)
    # if health <= 0:
    #     monitoring = false
    #     monitorable = false
    #     emit_signal("died")

func _on_died():
    monitoring = false
    monitorable = false
    emit_signal("died")
