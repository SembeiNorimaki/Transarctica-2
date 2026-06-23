extends GenericState
class_name UnitBehaviorEvaluate

# Tunable tactical thresholds
const LOW_HEALTH_THRESHOLD := 0.3
const GOOD_SHOT_THRESHOLD := 0.4


var unit: Unit = null

# used for xcom2 turn logic where a unit has 2 actions
var action_counter := 0

func _dummy():
	await get_tree().create_timer(2.0).timeout
	print("Evaluate: done")
	state_machine.emit_signal("state_finished")


# lets implement like xcom2. There are two actions


func enter(params = {}):
	unit = params.unit
	_evaluate_xcom2()
	

func exit(params = {}):
	pass

func update(delta: float):
	pass


func evaluate_xcom1():
	# 1) Dead?
	print("1) Checking if unit is dead")
	if not unit.is_alive:
		unit.unit_ai.turn_finished.emit()
		return

	# 2) No AP?
	print("2) Checking if unit has enough AP")
	# TODO: Instead of checking against 0, there should be a minimum amount of AP left
	if unit.get_ap() <= 0:
		unit.unit_ai.turn_finished.emit()
		return
	
	# 3) Enemy visible?
	
	var enemy = unit.unit_manager.get_primary_target_for(unit)
	print("3) Checking if an enemy is visible... %s" % ("Yes" if enemy else "No"))
	if enemy == null:
		# No enemy visible, enter overwatch
		state_machine.set_state("OverwatchState", {"unit": unit})
		return
	
	# 4) Low health -> Retreat or seek cover
	# TODO: Needs to be checked
	print("4) Checking unit health ratio: %s" % unit.get_health_ratio())
	if unit.get_health_ratio() < LOW_HEALTH_THRESHOLD:
		var safe_tile = unit.find_safe_tile()
		if safe_tile != unit.current_tile:
			unit.target_tile = safe_tile
			state_machine.set_state("RetreatState", {"unit": unit})
			return
		# If no safe tile exists, seek cover
		if not unit.is_in_cover_against_enemy(enemy):
			var cover_tile = unit.unit_manager.find_best_cover(unit, enemy)
			unit.target_tile = cover_tile
			state_machine.set_state("SeekCoverState", {"unit": unit})
			return
		# If already in cover, overwatch as fallback
		state_machine.set_state("OverwatchState", {"unit": unit})
		return
	
	# 5) Flanked (no directional cover)
	# TODO: Needs to be checked
	var incover = unit.unit_manager.is_unit_in_cover_against_enemy(unit, enemy)
	print("5) Checking if unit is in cover: %s" % ("Yes" if incover else "No"))
	if not incover:
		var cover_tile = unit.unit_manager.find_best_cover(unit, enemy)
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
	print("6) Checking if unit has good shoot")
	if unit.has_good_shoot(enemy):
		state_machine.set_state("AttackState", {"unit": unit, "target_tile": enemy.current_tile})
		return
	
	# 7) In cover but no good shoot -> overwatch or advance
	print("7) Checking if unit is in cover but no good shoot")
	if unit.is_in_cover_against_enemy(enemy):
		if unit.should_overwatch():
			state_machine.set_state("OverwatchState", {"unit": unit})
			return
		var adv_tile = unit.find_advance_tile(enemy.current_tile)
		unit.target_tile = adv_tile
		state_machine.set_state("AdvanceState", {"unit": unit, "target": enemy})
		return
	
	# 8) Fallback: advance
	print("8) Fallback: advance")
	var adv_tile = unit.find_advance_tile(enemy.current_tile)
	unit.target_tile = adv_tile
	state_machine.set_state("AdvanceState", {"unit": unit, "target": enemy})
	

	state_machine.state_finished.emit()

func _evaluate_xcom2():
	action_counter += 1
	
	match action_counter:
		1: _do_action_1()
		2: _do_action_2()
		_: print("Invalid action number: %s" % action_counter)
	
	unit.unit_ai.turn_finished.emit()

func _do_action_1():
	print("Doing action 1")
	await get_tree().create_timer(1.0).timeout


	# Look left and right to see if there are enemies
	unit.turn_left(1)
	await get_tree().create_timer(1.0).timeout
	unit.turn_right(2)
	await get_tree().create_timer(1.0).timeout
	unit.turn_left(1)
	await get_tree().create_timer(1.0).timeout

	unit.unit_ai.turn_finished.emit()
	return
	

	var enemies = unit.unit_manager.get_seen_enemies_for(unit)
	print("Unit sees %s enemies" % enemies.size())


	# 1) No enemies known by the unit
	if enemies.size() == 0:
		pass

	# 2) Immediate danger: not in cover against any visible enemy
	if not unit.unit_manager.is_unit_in_cover_against_all_enemies(unit, enemies):
		print("Unit not in cover, seeking cover")
		state_machine.set_state("SeekCoverState", {"unit": unit, "enemies": enemies})
		return
	
	# 3) Low health
	print("Checking low health")
	if unit.get_health_ratio() < LOW_HEALTH_THRESHOLD:
		state_machine.set_state("RetreatState", {"unit": unit, "enemies": enemies})
		return

	# Select best enemy to attack
	var enemy = unit.unit_manager.choose_best_target(unit, enemies)
	if enemy == null:
		pass


	# 3) Flanking opportunity
	print("Checking flanking opportunity")
	var flank_tile = unit.find_flanking_tile(enemy)
	if flank_tile and flank_tile != unit.current_tile:
		print("Action1: Flanking opportunity → move to flank")
		unit.target_tile = flank_tile
		#_perform_move()
		return
	
	# 4) Already in good cover + good shot → shoot
	print("Checking good shot")
	if unit.has_good_shoot(enemy):
		state_machine.set_state("AttackState", {"unit": unit, "target_tile": enemy.current_tile})
		return


func _do_action_2():
	print("Doing action 2")
	await get_tree().create_timer(1.0).timeout


func on_unit_reached_destination(unit):
	print("Evaluate: on_unit_reached_destination")
	unit.unit_ai.turn_finished.emit()
