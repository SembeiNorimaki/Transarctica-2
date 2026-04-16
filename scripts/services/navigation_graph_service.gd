extends Node
class_name NavigationGraphService

# Injected services 
var grid_service: GridService # conversions between tile, world, and screen coordinates
var terrain_service: TerrainService
var tile_occupancy_service: TileOccupancyService # whether a tile is occupied by a unit, building or wall
var edge_occupancy_service: EdgeOccupancyService

var nodes := {} # Dictionary: tile(Vector2i) -> NodeData
var nodes2x2 := {} # Dictionary: anchor(Vector2i) -> NodeData
var edges := {} # Dictionary: (tileA, tileB) -> EdgeData
var edges2x2 := {} # Dictionary: (anchorA, anchorB) -> EdgeData
var adjacency := {} # Dictionary: tile(Vector2i) -> Array[EdgeData]
var adjacency2x2 := {} # Dictionary: anchor(Vector2i) -> Array[EdgeData]

# Internal edge obstacles
#var blocked_edges := {} # Dictionary: key -> bool

class NodeData:
	var tile: Vector2i
	var walkable: bool
	var terrain_cost: float
	var elevation: int
	
# class EdgeData:
# 	var from_tile: Vector2i
# 	var to_tile: Vector2i
# 	var cost: float

func build_graph():
	nodes.clear()
	nodes2x2.clear()
	edges.clear()
	edges2x2.clear()
	adjacency.clear()
	adjacency2x2.clear()
	#blocked_edges.clear()

	_build_nodes()
	_build_edges()
	_build_nodes_2x2()
	_build_edges_2x2()


# #region Public API
func is_walkable_2x2(anchor: Vector2i) -> bool:
	var footprint = [
		anchor,
		anchor + Vector2i(1, 0),
		anchor + Vector2i(0, 1),
		anchor + Vector2i(1, 1)
	]
	for tile in footprint:
		if not grid_service.is_inside_map(tile):
			return false
		if tile_occupancy_service.is_occupied_static(tile):
			return false
	return true

# func block_edge(a: Vector2i, b: Vector2i):
# 	blocked_edges[_edge_key(a, b)] = true
# 	_update_edge(a, b)

# func unblock_edge(a: Vector2i, b: Vector2i):
# 	blocked_edges.erase(_edge_key(a, b))
# 	_update_edge(a, b)

# func is_edge_walk_blocked(a: Vector2i, b: Vector2i) -> bool:
# 	return blocked_edges.has(_edge_key(a, b))
# #endregion


#region Graph Construction
func _build_nodes():
	var map_size = grid_service.map_size
	for x in range(map_size.x):
		for y in range(map_size.y):
			var tile := Vector2i(x, y)

			var node = NodeData.new()
			node.tile = tile
			node.walkable = not tile_occupancy_service.is_occupied_static(tile)
			node.terrain_cost = terrain_service.get_cost(tile)
			node.elevation = terrain_service.get_elevation(tile)
			
			nodes[tile] = node
	#print("Nodes", nodes.keys())
	##print("Number of nodes: %s" % nodes.size())

func _build_nodes_2x2():
	var map_size = grid_service.map_size
	for x in range(map_size.x):
		for y in range(map_size.y):
			var anchor = Vector2i(x, y)
			
			if not is_walkable_2x2(anchor):
				continue
				
			# create node
			var node = NodeData.new()
			node.tile = anchor
			node.walkable = true
			node.terrain_cost = terrain_service.get_cost(anchor)
			node.elevation = terrain_service.get_elevation(anchor)
			
			nodes2x2[anchor] = node

func _build_edges():
	for tile in nodes.keys():
		if not nodes[tile].walkable:
			continue

		adjacency[tile] = []

		for neighbor in grid_service.get_neighbors(tile):
			if not nodes.has(neighbor):
				continue
			if not nodes[neighbor].walkable:
				continue
			if edge_occupancy_service.is_edge_walk_blocked(tile, neighbor):
				continue

			var edge = edge_occupancy_service.get_edge(tile, neighbor)
			# If no edge exists, create a normal edge
			if edge == null:
				edge = EdgeFactory.create_edge(tile, neighbor)

			# Skip edges that block movement
			if edge.blocks_movement:
				continue
			# update cost based on terrain
			edge.cost = nodes[neighbor].terrain_cost

			#store in adjacency list
			adjacency[tile].append(edge)

			# Optional: keep global edge dict for debugging
			edges[_edge_key(tile, neighbor)] = edge
	
	##print("Number of edges: %s" % edges.size())

func _build_edges_2x2():
	for anchor in nodes2x2.keys():
		# anchor is guaranteed to be walkable 2x2
		adjacency2x2[anchor] = []

		for neighbor in grid_service.get_neighbors(anchor):
			if not nodes2x2.has(neighbor):
				continue
			
			# Check edge blocking
			if edge_occupancy_service.is_edge_walk_blocked(anchor, neighbor):
				continue

			var edge = edge_occupancy_service.get_edge(anchor, neighbor)
			# If no edge exists, create a normal edge
			if edge == null:
				edge = EdgeFactory.create_edge(anchor, neighbor)

			# Skip edges that block movement
			if edge.blocks_movement:
				continue
			# update cost based on terrain
			edge.cost = nodes2x2[neighbor].terrain_cost

			#store in adjacency list
			adjacency2x2[anchor].append(edge)

			# Optional: keep global edge dict for debugging
			edges2x2[_edge_key(anchor, neighbor)] = edge

func _edge_key(a: Vector2i, b: Vector2i) -> String:
	return str(a) + "_" + str(b)

func _update_edge(a: Vector2i, b: Vector2i):
	var key = _edge_key(a, b)
	if edges.has(key):
		edges[key].walkable = edge_occupancy_service.is_edge_walk_blocked(a, b)
#endregion
