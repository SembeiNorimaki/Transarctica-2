extends Node
class_name AimingState

var machine: StateMachine
# Injected by CombatStateMachine
var parent_scene: Node2D

func _ready():
    machine = get_parent()

func enter(prev):
    print("Entered aiming state")

func exit(next):
    print("Exiting aiming state")

func handle_click(tile: Vector2i, button_index: int):
    pass