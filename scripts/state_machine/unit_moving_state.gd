extends Node
class_name UnitMovingState

var state_machine: CombatStateMachine
# Injected by CombatStateMachine
var combat_scene: Node2D
var selected_unit: Unit = null

func _ready():
	state_machine = get_parent()
