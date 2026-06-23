extends GenericState
class_name UnitBehaviorSeekCover

var unit: Unit = null
var enemies: Array = []

func enter(params = {}):
	unit = params.unit
	enemies = params.enemies

	
	var cover_tile = unit.unit_manager.find_safest_tile(unit, enemies)
	if cover_tile == null:
		# no best cover available
		return
		
	var path = unit.unit_manager.calculate_path_for_unit(unit, cover_tile)
	unit.unit_manager.start_unit_movement(unit, path)


func exit(params = {}):
	pass

func update(delta: float):
	pass
	#if unit.has_finished_moving():
	#	state_machine.set_state("UnitBehaviorEvaluate")
