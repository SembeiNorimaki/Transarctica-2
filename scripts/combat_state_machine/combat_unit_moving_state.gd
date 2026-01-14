extends GenericState
class_name UnitMovingState

# Injected by CombatStateMachine
var selected_unit: Unit = null

func _ready():
	pass

func enter(prev, params = {}):
	print("Enter combat unit moving state with params %s", params)
	selected_unit = params["selected_unit"]
	#parent_scene.selection_manager.select_unit(selected_unit)

func exit(next, params = {}):
	pass
	#parent_scene.selection_manager.clear_selection()

func update(delta: float):
	pass

func handle_click(tile: Vector2i, button_index: int):
	pass
