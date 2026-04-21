extends Node
class_name PodAIManager

# Injected by CombatScene
var pod_manager : PodManager
var unit_manager: UnitManager

func _ready() -> void:
	pass

func execute_turn():
	print("PodAIManager execute turn")
	for pod in pod_manager.get_all_pods():
		print("Executing pod %s" % pod.id)
		dumb_pod_action(pod)
	#var enemy_units = unit_manager.get_units_by_team("Enemy")
	#for enemy_unit in enemy_units:
	#	print(enemy_unit.id)
	#	dumb_unit_action(enemy_unit)

func dumb_pod_action(pod: Pod):
	# get all units in the pod:
	print("Dumb pod action for pod %s" % pod.id)
	var patrol_route = pod_manager.get_pod_patrol_route(pod.id)
	print("Patrol for pod: %s", patrol_route)
	for unit in pod.get_all_units():
		print("Unit %s belonging to pod %s" % [unit.id, pod.id])
		var preview_path : Array[Vector2i] = [
			unit.current_tile + Vector2i(0, 0),
			unit.current_tile + Vector2i(-1, 0)
		]	
		unit_manager.start_unit_movement(unit, patrol_route)
	
	pass
	# just move the unit 2 tiles west
	# var preview_path : Array[Vector2i] = [
	# 	unit.current_tile + Vector2i(0, 0),
	# 	unit.current_tile + Vector2i(-1, 0),
	# 	unit.current_tile + Vector2i(-2, 0)
	# ]

	#unit_manager.start_unit_movement(unit, preview_path)
