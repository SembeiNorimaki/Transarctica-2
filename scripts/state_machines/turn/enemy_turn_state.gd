extends GenericState
class_name EnemyTurnState


func enter(params = {}):
	var faction_ai = owner_node.faction_ai
	faction_ai.faction_finished.connect(_on_faction_finished, CONNECT_ONE_SHOT)
	faction_ai.take_turn()

# called when faction_ai emits the signal faction_finished
func _on_faction_finished():
	state_machine.set_state("PlayerTurnState")
