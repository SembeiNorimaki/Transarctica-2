extends GenericState
class_name UnitBehaviorOverwatch

var unit: Unit = null

func enter(params = {}):
	unit = params.unit
	print("Overwatch state entered")
	#unit.enter_overwatch()
	#unit.spend_ap(1)
	unit.unit_ai.turn_finished.emit()
	
	#unit.enter_overwatch()
	#unit.end_turn()
	#state_machine.set_state("UnitBehaviorIdle")

func exit(params = {}):
	pass

func update(delta: float):
	pass
