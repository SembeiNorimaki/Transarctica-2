extends Node
class_name ApComponent

signal ap_changed(current: int, max: int)
signal ap_exhausted

@export var max_ap: int = 100
var current_ap: int

func _ready():
    reset_ap()

func use_ap(amount: int):
    current_ap = max(0, current_ap - amount)
    emit_signal("ap_changed", current_ap, max_ap)
    if current_ap == 0:
        emit_signal("ap_exhausted")

func reset_ap():
    current_ap = max_ap
    emit_signal("ap_changed", current_ap, max_ap)
