extends Node
class_name PodManager

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService

var pods_to_tile := {} # Dict of pods -> tile_position
var tile_to_pod := {}
var pods: Array[Pod] = []
var pods_units := {} # Dict pod_id -> ["Unit": Unit, "Formation_offset": Vector2i]
var pods_by_id := {}
var pods_paths := {} # Dict of pods -> path
var pods_patrol_routes := {} # Dict of pods -> patrol routes

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
    pods_patrol_routes[id] = patrol_route

    pods.append(pod)
    pods_by_id[id] = pod
    pods_units[id] = []
    # Add to scene tree
    get_node("../../Containers/Pods").add_child(pod)

    # Register in occupancy
    tile_occupancy_service.register(tile_pos, pod)

    # Register in pods_to_tile
    pods_to_tile[pod] = tile_pos
    tile_to_pod[tile_pos] = pod

    emit_signal("pod_spawned", pod)

func add_unit_to_pod(pod_id: String, unit: Unit, formation_offset: Vector2i):
    var pod = pods_by_id[pod_id]
    pod.add_unit(unit)
    
    pods_units[pod_id].append({"unit": unit, "formation_offset": formation_offset})

#region Public API
func get_pod_by_tile(tile: Vector2i):
    return tile_to_pod[tile]
func get_pod_tile(pod: Pod):
    return pods_to_tile[pod]
func get_pod_patrol_route(id_: String) -> Array[Vector2i]:
    return pods_patrol_routes[id_]

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


#region Movement orchestration
func start_pod_movement(pod: Pod, path: Array[Vector2i]) -> void:
    path.pop_front() # remove first point since it's the current tile
    pods_paths[pod] = path
    _give_next_tile(pod)
    pod.set_state("MoveState", {"pod": pod})

func _give_next_tile(pod: Pod) -> void:
    var path = pods_paths[pod]
    if path.is_empty():
        _on_pod_reached_destination(pod)
    else:
        var next_tile = path.pop_front()
        pod.move_to_tile(next_tile)

func _on_pod_reached_destination(pod):
    print("Pod reached destination")
    # set the unit state to idle
    pod.set_state("IdleState", {"pod": pod})
    #unit.play_animation("IdleState", unit.orientation)
    #emit_signal("pod_reached_destination", pod)
