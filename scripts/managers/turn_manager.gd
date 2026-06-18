extends Node
class_name TurnManager

# signal turn_started(team_id)
# signal turn_ended(team_id)
# signal unit_activated(unit)
# signal unit_finished(unit)

#Injected dependencies
#var unit_manager: UnitManager
#var pod_manager: PodManager
var faction_ai: FactionAI # needed by enemy_turn_state
#var pod_ai_manager: PodAIManager
#var selection_manager: SelectionManager

@onready var turn_state_machine: StateMachine = $TurnStateMachine


# Turn state
#var teams := [] # ["player", "enemy", ...]
#var units_by_team := {} # team_id -> Array[Unit]
#var current_team_index := 0
#var current_unit_index := 0

#var active_team = null
#var active_unit = null
#var combat_started := false

func start_combat() -> void:
	turn_state_machine.set_state("PlayerTurnState")

func finish_turn():
	if turn_state_machine.get_current_state() == "PlayerTurnState":
		turn_state_machine.set_state("EnemyTurnState")
	else:
		turn_state_machine.set_state("PlayerTurnState")

# When Faction_AI finishes its turn this function will be called
func _on_faction_finished():
	# switch to player turn
	finish_turn()


func update_state_label(state_name) -> void:
	pass


#Initialization
# func register_team(team_id: String) -> void:
# 	if not teams.has(team_id):
# 		teams.append(team_id)
# 		units_by_team[team_id] = []

# func register_unit(team_id: String, unit: Unit) -> void:
# 	if not units_by_team.has(team_id):
# 		push_error("TurnManager: team '%s' not registered" % team_id)
# 		return
# 	units_by_team[team_id].append(unit)


# func _change_state(new_state):
# 	if current_state:
# 		current_state.exit()
# 	current_state = new_state
# 	new_state.enter()


	# if teams.is_empty():
	# 	push_error("TurnManager: no teams registered")
	# 	return
	
	# combat_started = true
	# current_team_index = 0
	# _start_team_turn()

# Turn flow
# func _start_team_turn() -> void:
# 	active_team = teams[current_team_index]
# 	# Remove dead units before starting the turn
# 	_cleanup_dead_units(active_team)

# 	current_unit_index = 0

# 	emit_signal("turn_started", active_team)
# 	_activate_next_unit()

# func _activate_next_unit() -> void:
# 	var team_units = units_by_team[active_team]
	
# 	# If no units remain, skip team
# 	if team_units.is_empty():
# 		_end_team_turn()
# 		return

# 	# If we reached the end of the list, end team turn
# 	if current_unit_index >= team_units.size():
# 		_end_team_turn()
# 		return

# 	active_unit = team_units[current_unit_index]
	
# 	# Skip dead units
# 	if active_unit.is_dead():
# 		current_unit_index += 1
# 		_activate_next_unit()
# 		return

# 	# Highlight the active unit
# 	if selection_manager:
# 		selection_manager.select_unit(active_unit)

# 	emit_signal("unit_activated", active_unit)

# func finish_unit_turn() -> void:
# 	if not combat_started:
# 		return

# 	emit_signal("unit_finished", active_unit)
# 	current_unit_index += 1
# 	_activate_next_unit()

# func _end_team_turn() -> void:
# 	emit_signal("turn_ended", active_team)
# 	current_team_index = (current_team_index + 1) % teams.size()
# 	_start_team_turn()

# Utility
# func _cleanup_dead_units(team_id: String) -> void:
# 	var unit_list = units_by_team[team_id]
# 	for unit in unit_list:
# 		if unit.is_dead():
# 			unit_list.remove(unit)
