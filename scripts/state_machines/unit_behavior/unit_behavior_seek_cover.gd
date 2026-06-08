extends GenericState
class_name UnitBehaviorSeekCover

var unit: Unit = null

func enter(params = {}):
	var cover_tile = unit.find_best_cover()
	if cover_tile:
		unit.move_to(cover_tile)
	else:
		state_machine.set_state("UnitBehaviorRetreat", {})

func exit(params = {}):
	pass

func update(delta: float):
	if unit.has_finished_moving():
		state_machine.set_state("UnitBehaviorEvaluate")
