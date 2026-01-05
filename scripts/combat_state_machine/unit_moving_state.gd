extends Node
class_name UnitMovingState

var state_machine: StateMachine
# Injected by CombatStateMachine
var parent_scene: Node2D
var selected_unit: Unit = null

func _ready():
	state_machine = get_parent()

func enter(prev):
	print("Entered unit selected state with unit %s" % selected_unit)
	#parent_scene.selection_manager.select_unit(selected_unit)

func exit(next):
	print("Exiting unit selected state")
	#parent_scene.selection_manager.clear_selection()

func handle_click(tile: Vector2i, button_index: int):
	pass