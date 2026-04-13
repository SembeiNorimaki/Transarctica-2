extends GenericState
class_name EnemyTurnState


func enter(params = {}):
	print("Enter enemy turn state %s, %s" % [owner_node.pod_manager, owner_node.unit_ai_manager])
	await _run_units()
	state_machine.set_state("PlayerTurnState")


func _run_units():
	var unit_ai_manager = owner_node.unit_ai_manager
	unit_ai_manager.execute_turn()
	
	# pass

func _run_pods():
	var pods = owner_node.pod_manager.get_all_pods()
	for pod in pods:
		pod.take_turn()
		await pod.turn_finished	
# extends GenericState
# class_name EnemyTurnState

# var tm: TurnManager
# var units := []
# var index := 0


# func _init(tm_):
#     tm = tm_
   
# func enter(params = {}):
#     #print("Enemy Turn State Enter")
#     units = tm.unit_manager.get_units_for_team("enemy")
#     units = units.filter(func(u): return not u.is_dead())
#     #print("Enter Enemy turn state. Enemy units: %s" % units)
#     index = 0

#     tm.emit_signal("turn_started", "enemy")
#     _activate_next_unit()

# func exit(params = {}):
#     pass

# func _activate_next_unit():
#     if index >= units.size():
#         tm.emit_signal("turn_ended", "enemy")
#         tm.finish_turn()
#         return

#     var unit = units[index]
#     tm.emit_signal("unit_activated", unit)

#     # Later: AI controller goes here
#     # ai_controller.take_turn(unit)

# func on_unit_finished():
#     tm.emit_signal("unit_finished", units[index])
#     index += 1
#     _activate_next_unit()
