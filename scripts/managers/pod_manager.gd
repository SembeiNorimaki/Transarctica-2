extends Node
class_name PodManager

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService

var pods_to_tile := {} # Dict of pods -> tile_position

var pods: Array[Pod] = []
var pods_by_id := {}

var cycle_idx = -1
signal pod_spawned(pod)

const POD_SCENE = preload("res://scenes/entities/pods/pod.tscn")

func spawn_pod(id: String, tile_pos: Vector2i, patrol_route: Array[Vector2i]) -> void:
	#print("Spawning pod %s at tile %s" % [id, tile_pos])
	var pod: Pod = POD_SCENE.instantiate()

	# Dependency injection
	pod.grid_service = grid_service
	pod.pod_manager = self

	pod.call_deferred("initialize", id)
	pod.position = grid_service.tile_to_world(tile_pos)
	pod.current_tile = tile_pos
	pod.patrol_route = patrol_route

	pods.append(pod)
	pods_by_id[id] = pod
	# Add to scene tree
	get_node("../../Containers/Pods").add_child(pod)

	# Register in occupancy
	tile_occupancy_service.register(tile_pos, pod)

	# Register in pods_to_tile
	pods_to_tile[pod] = tile_pos

	emit_signal("pod_spawned", pod)

func add_units_to_pod(pod_id: String, units: Array[Unit]):
	var pod = pods_by_id[pod_id]
	for unit in units:
		pod.units.append(unit)

#region Public API

func get_next_pod() -> Pod:
	if pods.is_empty():
		return null
	cycle_idx = (cycle_idx + 1) % pods.size()
	return pods[cycle_idx]

func get_all_pods() -> Array[Pod]:
	var all_pods: Array[Pod] = []
	for pod in pods:
		all_pods.append(pod)
	return all_pods
#endregion

func register_pod(pod: Pod):
	pods.append(pod)

func unregister_pod(pod: Pod):
	pods.erase(pod)
