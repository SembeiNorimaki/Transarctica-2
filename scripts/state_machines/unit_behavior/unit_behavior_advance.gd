extends GenericState
class_name UnitBehaviorAdvance

var unit: Unit = null

func enter(params = {}):
	var enemy = params.target
	unit = params.unit
	if enemy:
		var tile = unit.find_advance_tile(enemy.current_tile)
		unit.move_to(tile)
	else:
		# print("No enemy to advance against")
		pass

func exit(params = {}):
    pass

func update(delta: float):
	# print("Unit is advancing...")
	await get_tree().create_timer(0.5).timeout
	state_machine.set_state("EvaluateState", {"unit": unit})

    #if unit.has_finished_moving():
    #    state_machine.set_state("UnitBehaviorEvaluate")
