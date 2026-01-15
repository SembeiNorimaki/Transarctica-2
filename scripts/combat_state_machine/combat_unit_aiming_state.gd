extends GenericState
class_name AimingState

# Injected by CombatStateMachine

var selected_unit: Unit = null

func _ready():
	pass

func enter(params = {}):
	print("Enter AimingState with params %s" % params)
	selected_unit = params["selected_unit"]

func exit(params = {}):
	pass

func update(delta: float):
	pass

func handle_click(tile: Vector2i, button_index: int):
	print("CUAS click %s" % tile)

func handle_key(event: InputEventKey):
	print("CUAS handle key %s" % event)
	if event.is_action_pressed("tab"):
		owner_node.select_next_unit()
