extends Node
class_name UnitAI

@onready var owner_node = get_parent()
@onready var behavior_state_machine: StateMachine = $BehaviorStateMachine


# EvaluateState emits this signal
signal turn_finished


func _ready():
    behavior_state_machine.states.EvaluateState.action_finished.connect(_on_action_finished)

# This is annoyingly needed because state machine requires it. Should be changed
func update_state_label(_name: String):
    pass

func take_turn() -> void:
    # print("UnitAI TakeTurn started")
    behavior_state_machine.set_state("EvaluateState", {"unit": owner_node})

func _on_action_finished():
    if behavior_state_machine.states.EvaluateState.is_anything_left_to_do():
        behavior_state_machine.states.EvaluateState.take_next_action()
    else:
        turn_finished.emit()
