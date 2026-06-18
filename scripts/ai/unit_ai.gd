extends Node
class_name UnitAI

@onready var owner_node = get_parent()
@onready var behavior_state_machine: StateMachine = $BehaviorStateMachine


# EvaluateState emits this signal
signal turn_finished


func _ready():
	pass

# This is annoyingly needed because state machine requires it. Should be changed
func update_state_label(_name: String):
	pass

func take_turn() -> void:
	print("UnitAI TakeTurn started")
	behavior_state_machine.set_state("EvaluateState", {"unit": owner_node})

	#print("      Unit ", owner.name, " starting turn")	
	# Start the behavior loop
	# Wait until EvaluateState decides the turn is finished
	#await turn_finished
	# After the turn is done, return to idle
	#behavior_state_machine.set_state("IdleState", {"unit": owner_node})
	#print("      Unit ", owner.name, " finished turn.")

func _on_unit_arrived_to_tile(_unit, _new_tile: Vector2i):
	pass

func on_unit_reached_destination(unit):
	behavior_state_machine.states.EvaluateState.on_unit_reached_destination(unit)
