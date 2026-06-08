extends GenericState
class_name UnitBehaviorAttack

var unit: Unit = null

func enter(params = {}):
	unit.shoot(unit.current_target)

func exit(params = {}):
	pass

func update(delta: float):
	if unit.has_finished_shooting():
		state_machine.set_state("UnitBehaviorEvaluate")
