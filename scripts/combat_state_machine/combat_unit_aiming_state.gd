extends Node
class_name AimingState

var machine: StateMachine
# Injected by CombatStateMachine
var parent_scene: Node2D
var selected_unit: Unit = null

func _ready():
    machine = get_parent()

func enter(prev, params={}):
    selected_unit = params["selected_unit"]

func exit(next, params={}):
    pass

func update(delta: float):
    pass

func handle_click(tile: Vector2i, button_index: int):
    pass

func handle_key(event: InputEventKey):
    if event.is_action_pressed("tab"): 
        parent_scene.select_next_unit()