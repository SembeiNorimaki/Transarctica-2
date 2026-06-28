extends Node
class_name NavigationGraphService


# nodes:  Dictionary: tile(Vector2i) -> NodeData
# built from terrain_tilemap and used to build edges
# where NodeData:
#    tile: Vector2i
#    walkable: bool        = not tile_occupancy_service.is_occupied_static(tile)
#    terrain_cost: float   = terrain_service.get_cost(tile)
#    elevation: int        = terrain_service.get_elevation(tile)
#
# edges: # Dictionary: (tileA, tileB) -> Edge  (using EdgeFactory)
# built from nodes and used by adjacency
#   both nodes must be walkable
#   edge_occupancy_service.is_edge_walk_blocked will not create an edge
#   It just creates a normal edge. TODO: Shall other types of edges be created?

# Injected services 
var grid_service: GridService
var terrain_service: TerrainService
var tile_occupancy_service: TileOccupancyService # whether a tile is occupied by a unit, building or wall
var edge_occupancy_service: EdgeOccupancyService
var reachable_tiles_overlay: ReachableTilesOverlay

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
#     var from_tile: Vector2i
#     var to_tile: Vector2i
#     var cost: float

func build_graph(terrain_tilemap: TileMapLayer):
    # print("Building navigation graph")
    nodes.clear()
    nodes2x2.clear()
    edges.clear()
    edges2x2.clear()
    adjacency.clear()
    adjacency2x2.clear()
    #blocked_edges.clear()

    _build_nodes(terrain_tilemap)
    _build_edges()
    _build_nodes_2x2(terrain_tilemap)
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

func get_reachable_tiles(unit: Unit, max_cost: float) -> Array[Vector2i]:
    var start := unit.current_tile
    var footprint := 1
    
    # select the correct adjacency graph
    var graph_adj := adjacency
    if footprint == 2:
        graph_adj = adjacency2x2

    if not graph_adj.has(start):
        return []

    var reachable: Array[Vector2i] = []
    var g_cost := {} # tile -> cost
    var visited := {} # tile -> bool
    var open := [] # priority queue [ {tile, cost} ]
    var came_from := {} # tile -> predecessor tile

    g_cost[start] = 0.0
    
    open.append({"tile": start, "cost": 0.0})

    while open.size() > 0:
        # pop lowest cost entry
        open.sort_custom(_compare_cost)
        var current = open.pop_front()
        var tile: Vector2i = current.tile
        var cost: float = current.cost

        if visited.has(tile):
            continue
        visited[tile] = true

        reachable.append(tile)

        # Explore neighbors
        for edge in graph_adj[tile]:
            var neighbor = edge.to_tile
            if visited.has(neighbor):
                continue

            var new_cost = cost + edge.cost
            if new_cost > max_cost:
                continue
            
            if new_cost < g_cost.get(neighbor, INF):
                g_cost[neighbor] = new_cost
                came_from[neighbor] = tile
                open.append({"tile": neighbor, "cost": new_cost})
    
    #print("Reachable tiles:",  reachable)
    reachable_tiles_overlay.show_tiles(reachable, came_from)
    return reachable


# Priority queue comparator
func _compare_cost(a, b):
    return a.cost < b.cost
       
# func block_edge(a: Vector2i, b: Vector2i):
#     blocked_edges[_edge_key(a, b)] = true
#     _update_edge(a, b)

# func unblock_edge(a: Vector2i, b: Vector2i):
#     blocked_edges.erase(_edge_key(a, b))
#     _update_edge(a, b)

# func is_edge_walk_blocked(a: Vector2i, b: Vector2i) -> bool:
#     return blocked_edges.has(_edge_key(a, b))
# #endregion


#region Graph Construction
func _build_nodes(terrain_tilemap: TileMapLayer):
    var tiles = terrain_tilemap.get_used_cells()
    for tile in tiles:
        var node = NodeData.new()
        node.tile = tile
        node.walkable = not tile_occupancy_service.is_occupied_static(tile)
        node.terrain_cost = terrain_service.get_cost(tile)
        node.elevation = terrain_service.get_elevation(tile)
        
        nodes[tile] = node

func _build_nodes_2x2(terrain_tilemap: TileMapLayer):
    var tiles = terrain_tilemap.get_used_cells()
    for tile in tiles:
        if not is_walkable_2x2(tile):
            continue
        
        # create node
        var node = NodeData.new()
        node.tile = tile
        node.walkable = true
        node.terrain_cost = terrain_service.get_cost(tile)
        node.elevation = terrain_service.get_elevation(tile)
        
        nodes2x2[tile] = node

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
                # print("Wall found between %s and %s" % [tile, neighbor])
                continue

            # prevent diagonal cutting
            var delta = neighbor - tile
            
            # if it's a diagonal
            if abs(delta.x) == 1 and abs(delta.y) == 1:
                var side1 := Vector2i(tile.x + delta.x, tile.y)
                var side2 := Vector2i(tile.x, tile.y + delta.y)

                if not nodes.has(side1) or not nodes[side1].walkable:
                    continue
                if not nodes.has(side2) or not nodes[side2].walkable:
                    continue

                # the existence of walls also prevents diagonal cutting
                if edge_occupancy_service.is_edge_walk_blocked(tile, side1):
                    continue
                if edge_occupancy_service.is_edge_walk_blocked(tile, side2):
                    continue
                if edge_occupancy_service.is_edge_walk_blocked(side1, neighbor):
                    continue
                if edge_occupancy_service.is_edge_walk_blocked(side2, neighbor):
                    continue


            var edge = edge_occupancy_service.get_edge(tile, neighbor)
            # If no edge exists, create a normal edge
            if edge == null:
                edge = EdgeFactory.create_edge(tile, neighbor)

            # if it's a diagonal
            if abs(delta.x) == 1 and abs(delta.y) == 1:
                edge.cost = 1.4142
            else:
                edge.cost = 1.0

            # Skip edges that block movement
            if edge.blocks_movement:
                continue

            # update cost based on terrain
            #edge.cost = nodes[neighbor].terrain_cost

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
