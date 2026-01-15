extends Node
class_name PathfindingService

var tile_occupancy_service: TileOccupancyService
var terrain_service: TerrainService
var road_service: RoadService
var navigation_graph_service: NavigationGraphService

# 8-directional movement offsets
const DIRECTIONS = [
	Vector2i(-1, 1), # SW
	Vector2i(-1, 0), # W
	Vector2i(-1, -1), # NW
	Vector2i(0, -1), # N
	Vector2i(1, -1), # NE
	Vector2i(1, 0), # E
	Vector2i(1, 1), # SE
	Vector2i(0, 1) # S
]

func find_path(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	print("Pathfinding from", start, "to", goal)
	if start == goal:
		return [start]

	# --- Priority queue implemented as a sorted array ---
	var open_set := []
	_push_open(open_set, start, 0)

	var came_from := {}
	var g_score := {start: 0}
	var f_score := {start: heuristic(start, goal)}

	var closed := {}

	while open_set.size() > 0:
		var current: Vector2i = _pop_open(open_set)

		if current == goal:
			return _reconstruct_path(came_from, current)

		closed[current] = true
		print("current", navigation_graph_service.adjacency.keys())
		print("current", current)
		for edge in navigation_graph_service.adjacency[current]:
			var neighbor = edge.to_tile
			
			if closed.has(neighbor):
				continue

			# Blocked by units/buildings/walls?
			if tile_occupancy_service.is_occupied(neighbor):
				continue

			# Terrain cost
			var tile_cost = edge.cost
			if tile_cost >= INF:
				continue

			# Road modifier
			#tile_cost += road_service.get_movement_modifier(neighbor)

			var tentative_g: float = g_score.get(current, INF) + tile_cost

			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + heuristic(neighbor, goal)
				_push_open(open_set, neighbor, f_score[neighbor])

	return [] # No path found

func find_path2(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	print("Pathfinding from", start, "to", goal)
	if start == goal:
		return [start]

	# --- Priority queue implemented as a sorted array ---
	var open_set := []
	_push_open(open_set, start, 0)

	var came_from := {}
	var g_score := {start: 0}
	var f_score := {start: heuristic(start, goal)}

	var closed := {}

	while open_set.size() > 0:
		var current: Vector2i = _pop_open(open_set)

		if current == goal:
			return _reconstruct_path(came_from, current)

		closed[current] = true

		for dir: Vector2i in DIRECTIONS:
			var neighbor := current + dir

			if closed.has(neighbor):
				continue

			# Blocked by units/buildings/walls?
			if tile_occupancy_service.is_occupied(neighbor):
				continue

			
			# Terrain cost
			var tile_cost: float = terrain_service.get_cost(neighbor)
			if tile_cost >= INF:
				continue

			# Road modifier
			#tile_cost += road_service.get_movement_modifier(neighbor)

			var tentative_g: float = g_score.get(current, INF) + tile_cost

			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + heuristic(neighbor, goal)
				_push_open(open_set, neighbor, f_score[neighbor])

	return [] # No path found


# --- Priority queue helpers (Option 1) ---
func _push_open(open_set: Array, tile: Vector2i, priority: int) -> void:
	open_set.append({"tile": tile, "priority": priority})
	open_set.sort_custom(func(a, b): return a.priority < b.priority)

func _pop_open(open_set: Array) -> Vector2i:
	return open_set.pop_front().tile

# --- A* helpers ---
func heuristic(a: Vector2i, b: Vector2i) -> int:
	# Manhattan distance for grid movement
	return abs(a.x - b.x) + abs(a.y - b.y)

func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [current]
	while came_from.has(current):
		current = came_from[current]
		path.push_front(current)
	return path
