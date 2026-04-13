extends Node
class_name UnitAIManager

# Injected by CombatScene
var unit_manager : UnitManager


func _ready() -> void:
	pass

func execute_turn():
	print("UnitAIManager execute turn")
	var enemy_units = unit_manager.get_units_by_team("Enemy")
	for enemy_unit in enemy_units:
		print(enemy_unit.id)
		dumb_unit_action(enemy_unit)

func dumb_unit_action(unit: Unit):
	# just move the unit 2 tiles west
	var preview_path : Array[Vector2i] = [
		unit.current_tile + Vector2i(0, 0),
		unit.current_tile + Vector2i(-1, 0),
		unit.current_tile + Vector2i(-2, 0)
	]

	unit_manager.start_unit_movement(unit, preview_path)
