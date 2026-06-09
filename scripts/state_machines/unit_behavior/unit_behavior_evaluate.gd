extends GenericState
class_name UnitBehaviorEvaluate

# Tunable tactical thresholds
const LOW_HEALTH_THRESHOLD := 0.3
const GOOD_SHOT_THRESHOLD := 0.4

func _dummy():
	await get_tree().create_timer(2.0).timeout
	print("Evaluate: done")
	state_machine.emit_signal("state_finished")

func enter(params = {}):
	var unit: Unit = params.unit
	
	# 1) Dead?
	print("Checking if unit is dead")
	if not unit.is_alive:
		unit.unit_ai.turn_finished.emit()
		return

	# 2) No AP?
	print("Checking if unit has enough AP")
	if unit.get_ap() <= 0:
		unit.unit_ai.turn_finished.emit()
		return
	
	# 3) Enemy visible?
	print("Checking if an enemy is visible")
	var enemy = unit.get_primary_target()
	if enemy == null:
		# No enemy visible, enter overwatch
		state_machine.set_state("OverwatchState", {"unit": unit})
		return
		
	unit.unit_ai.turn_finished.emit()
	return


	# 4) Low health -> Retreat or seek cover
	if unit.health_ratio < LOW_HEALTH_THRESHOLD:
		var safe_tile = unit.find_safe_tile()
		if safe_tile != unit.current_tile:
			unit.target_tile = safe_tile
			state_machine.set_state("RetreatState", {"unit": unit})
			return
		# If no safe tile exists, seek cover
		if not unit.is_in_cover_against_enemy(enemy):
			var cover_tile := unit.find_best_cover(enemy)
			unit.target_tile = cover_tile
			state_machine.set_state("SeekCoverState", {"unit": unit})
			return
		# If already in cover, overwatch as fallback
		state_machine.set_state("OverwatchState", {"unit": unit})
		return
	
	# 5) Flanked (no directional cover)
	if not unit.is_in_cover_against_enemy(enemy):
		var cover_tile := unit.find_best_cover(enemy)
		if cover_tile != unit.current_tile:
			unit.target_tile = cover_tile
			state_machine.set_state("SeekCoverState", {"unit": unit})
			return
		# If no cover reachable, attack if possible
		if unit.has_good_shoot(enemy):
			state_machine.set_state("AttackState", {"unit": unit, "target": enemy})
			return
		# Otherwise, advance
		var adv_tile = unit.find_advance_tile(enemy.current_tile)
		unit.target_tile = adv_tile
		state_machine.set_state("AdvanceState", {"unit": unit, "target": enemy})
		return

	# 6) In cover and good shot -> attack
	if unit.has_good_shoot(enemy):
		state_machine.set_state("AttackState", {"unit": unit, "target": enemy})
		return
	
	# 7) In cover but no good shoot -> overwatch or advance
	if unit.is_in_cover_against_enemy(enemy):
		if unit.should_overwatch():
			state_machine.set_state("OverwatchState", {"unit": unit})
			return
		var adv_tile = unit.find_advance_tile(enemy.current_tile)
		unit.target_tile = adv_tile
		state_machine.set_state("AdvanceState", {"unit": unit, "target": enemy})
		return
	
	# 8) Fallback: advance
	var adv_tile = unit.find_advance_tile(enemy.current_tile)
	unit.target_tile = adv_tile
	state_machine.set_state("AdvanceState", {"unit": unit, "target": enemy})
	

	state_machine.state_finished.emit()

func exit(params = {}):
	pass

func update(delta: float):
	pass
