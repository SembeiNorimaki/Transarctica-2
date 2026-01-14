extends GenericState
class_name AimingState

# Injected by CombatStateMachine

var selected_unit: Unit = null

func _ready():
	pass

func enter(prev, params = {}):
	selected_unit = params["selected_unit"]

func exit(next, params = {}):
	pass

func update(delta: float):
	pass

func handle_click(tile: Vector2i, button_index: int):
	pass

func handle_key(event: InputEventKey):
	if event.is_action_pressed("tab"):
		owner_node.select_next_unit()
