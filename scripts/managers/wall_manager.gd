extends Node
class_name WallManager

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var edge_occupancy_service: EdgeOccupancyService
var grid_service: GridService

var walls_to_tile := {} # Dict of walls -> tile_position


signal wall_spawned(wall)


func spawn_full_wall(tile_pos: Vector2i, atlas_coords: Vector2i) -> void:
    var wall: WallFull = WallDatabase.WALL_FULL_SCENE.instantiate()

    # convert tile -> world
    var world_pos = grid_service.tile_to_world(tile_pos)
    wall.position = world_pos
    wall.current_tile = tile_pos
    var frame = atlas_coords.x
    wall.call_deferred("set_frame", frame)

    # Add to scene tree
    get_node("../../Containers/Walls").add_child(wall)

    # Register in occupancy
    var edge_type = Edge.EdgeType.WALL
    tile_occupancy_service.register(tile_pos, wall)
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(0, -1), edge_type)
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(0, 1), edge_type)
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(-1, 0), edge_type)
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(1, 0), edge_type)
    

    # Register in walls_to_tile
    #walls_to_tile[wall] = tile_pos
    emit_signal("wall_spawned", wall)

func spawn_left_wall(tile_pos: Vector2i, atlas_coords: Vector2i) -> void:
    var wall: WallEdge = WallDatabase.WALL_LEFT_SCENE.instantiate()
    var wall_name = WallDatabase.get_wall_name_from_coords(atlas_coords)

    # convert tile -> world
    var world_pos = grid_service.tile_to_world(tile_pos)
    wall.position = world_pos
    wall.current_tile = tile_pos

    wall.call_deferred("set_type", wall_name, "left")

    # Add to scene tree
    get_node("../../Containers/Walls").add_child(wall)

    # Register in occupancy
    var edge_type = WallDatabase.get_edge_type(atlas_coords)
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(-1, 0), edge_type)

    # Register in walls_to_tile
    #walls_to_tile[wall] = tile_pos
    emit_signal("wall_spawned", wall)


func spawn_right_wall(tile_pos: Vector2i, atlas_coords: Vector2i) -> void:
    var wall: WallEdge = WallDatabase.WALL_RIGHT_SCENE.instantiate()
    var wall_name = WallDatabase.get_wall_name_from_coords(atlas_coords)

    # convert tile -> world
    var world_pos = grid_service.tile_to_world(tile_pos)
    wall.position = world_pos
    wall.current_tile = tile_pos
    
    wall.call_deferred("set_type", wall_name, "right")

    # Add to scene tree
    get_node("../../Containers/Walls").add_child(wall)

    # Register in occupancy
    var edge_type = WallDatabase.get_edge_type(atlas_coords)
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(0, -1), edge_type)

    # Register in walls_to_tile
    #walls_to_tile[wall] = tile_pos
    emit_signal("wall_spawned", wall)


func apply_damage_to_wall(wall, amount: int):
    wall.apply_damage(amount)

func apply_damage_to_wall_edge(wall_edge: WallEdge, amount: int):
    wall_edge.apply_damage(amount)


# func spawn_wall(tile_pos, owner_id) -> void:
#     # #print("Spawning a wall at %s" % tile_pos)
#     var wall = WALL_SCENE.instantiate()
    
#     # convert tile -> world
#     var world_pos = grid_service.tile_to_world(tile_pos)
#     wall.position = world_pos

#     # Initialize unit data
#     wall.current_tile = tile_pos

#     # Add to scene tree
#     get_node("../../Containers/Walls").add_child(wall)

#     # Register in occupancy
#     tile_occupancy_service.register(tile_pos, wall)

#     # Register in walls_to_tile
#     walls_to_tile[wall] = tile_pos

    
#     emit_signal("wall_spawned", wall)


func _process(delta: float) -> void:
    pass
