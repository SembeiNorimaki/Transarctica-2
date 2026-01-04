extends Node
class_name AimingState

var machine: CombatStateMachine
# Injected by CombatStateMachine
var combat_scene: Node2D

func _ready():
    machine = get_parent()

func enter(prev):
    print("Entered aiming state")

func exit(next):
    print("Exiting aiming state")

func handle_click(tile: Vector2i, button_index: int):
    pass