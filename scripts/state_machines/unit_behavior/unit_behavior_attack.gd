extends GenericState
class_name UnitBehaviorAttack

var unit = null
var target_tile = null
var waiting_for_shot := false

func enter(params = {}):
	unit = params.unit
	target_tile = params.target_tile
	waiting_for_shot = false

	# Ask UnitManager to perform the shot
	var success = unit.unit_manager.request_shoot(unit, target_tile)
	if success:
		waiting_for_shot = true
	else:
		print("Could not shot")
		state_machine.set_state("UnitBehaviorEvaluate")

	
func exit(params = {}):
	pass

func update(delta: float):
	pass
