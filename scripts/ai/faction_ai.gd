extends Node
class_name FactionAI

# Injected by CombatScene
var unit_manager: UnitManager

signal turn_finished

func _ready() -> void:
	pass

func take_turn():
	_run_turn()


func _run_turn() -> void:
	print("Running CPU turn...")
	var enemy_units = unit_manager.get_units_by_team("Enemy")
	print("Number of enemy units: %s" % enemy_units.size())
	var idx := 0
	for unit in enemy_units:
		print("Running CPU unit %s" % idx)
		if not unit.is_alive:
			continue
		# 1) Select the unit visually, 
		unit_manager.select_unit(unit)
		# 2) Wait some time
		await get_tree().create_timer(1.0).timeout
		# # 3) Run the unit's AI turn
		await unit.unit_ai.take_turn()
		idx += 1

	turn_finished.emit()


# func _run_turn():
# 	print("UnitAIManager execute turn")
# 	var enemy_units = unit_manager.get_units_by_team("Enemy")
# 	for enemy_unit in enemy_units:
# 		print(enemy_unit.id)
# 		dumb_unit_action(enemy_unit)

# func dumb_unit_action(unit: Unit):
# 	# just move the unit 2 tiles west
# 	var preview_path : Array[Vector2i] = [
# 		unit.current_tile + Vector2i(0, 0),
# 		unit.current_tile + Vector2i(-1, 0),
# 		unit.current_tile + Vector2i(-2, 0)
# 	]

# 	unit_manager.start_unit_movement(unit, preview_path)
