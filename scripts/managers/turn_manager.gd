extends Node
class_name TurnManager

#Injected dependencies
var faction_ai: FactionAI # needed by enemy_turn_state

@onready var turn_state_machine: StateMachine = $TurnStateMachine

func start_combat() -> void:
    turn_state_machine.set_state("PlayerTurnState")

func finish_turn() -> void:
	if turn_state_machine.get_current_state() == "PlayerTurnState":
		turn_state_machine.set_state("EnemyTurnState")
	else:
		turn_state_machine.set_state("PlayerTurnState")

# When Faction_AI finishes its turn this function will be called
func _on_faction_finished():
    # switch to player turn
    finish_turn()

func get_current_state() -> String:
	return turn_state_machine.get_current_state()


func update_state_label(state_name) -> void:
	pass
