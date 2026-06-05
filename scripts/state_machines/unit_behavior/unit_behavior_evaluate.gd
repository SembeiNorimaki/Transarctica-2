extends GenericState
class_name UnitBehaviorEvaluate

func enter(params = {}):
	# Decide what to do this turn
	var unit: Unit = params["unit"]
	
	# 1) Dead?
	if unit.is_dead():
		state_machine.set_state("UnitBehaviorDead", {})
		return

	# 2) No AP?
	if unit.ap <= 0:
		unit.end_turn()
		state_machine.set_state("UnitBehaviorIdle", {})
		return
	
	# 3) See an enemy? SeekCover, if in cover, shoot, else advance
	if unit.can_see_player():
		if not unit.is_in_cover():
			state_machine.set_state("UnitBehaviorSeekCover", {})
		elif unit.has_good_shoot():
			state_machine.set_state("UnitBehaviorAttack", {})
		else:
			state_machine.set_state("UnitBehaviorAdvance", {})
		
	# 4) No enemy in sight, move toward player
	state_machine.set_state("UnitBehaviorAdvance", {})

func exit(params = {}):
	pass

func update(delta: float):
	pass
