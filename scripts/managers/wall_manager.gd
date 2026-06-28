extends Node
class_name WallManager

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var edge_occupancy_service: EdgeOccupancyService
var grid_service: GridService

var walls_to_tile := {} # Dict of walls -> tile_position

const WALL_SCENE = preload("res://scenes/entities/walls/wall.tscn")
const WALL_EDGE_SCENE = preload("res://scenes/entities/walls/wall_edge.tscn")


const ATLAS_COORDS_TO_EDGE_TYPE = {
    Vector2i(0, 0): Edge.EdgeType.WALL,
    Vector2i(1, 0): Edge.EdgeType.WALL,
    Vector2i(2, 0): Edge.EdgeType.WINDOW,
    Vector2i(3, 0): Edge.EdgeType.WINDOW,
    Vector2i(3, 3): Edge.EdgeType.DOOR,
    Vector2i(4, 3): Edge.EdgeType.DOOR,
    Vector2i(5, 3): Edge.EdgeType.DOOR,
    Vector2i(6, 3): Edge.EdgeType.DOOR,
    Vector2i(2, 5): Edge.EdgeType.NORMAL,
    Vector2i(3, 5): Edge.EdgeType.NORMAL
}


signal wall_spawned(wall)

func _ready() -> void:
    pass


func spawn_full_wall(tile_pos: Vector2i, atlas_coords: Vector2i) -> void:
    var wall = WALL_SCENE.instantiate()

    # convert tile -> world
    var world_pos = grid_service.tile_to_world(tile_pos)
    wall.position = world_pos
    wall.current_tile = tile_pos
    var frame = atlas_coords.y * 8 + atlas_coords.x
    wall.call_deferred("set_frame", frame)

    # Add to scene tree
    get_node("../../Containers/Walls").add_child(wall)

    # Register in occupancy
    # Register in occupancy
    
    # Register in occupancy
    var edge_type = ATLAS_COORDS_TO_EDGE_TYPE[atlas_coords]
    tile_occupancy_service.register(tile_pos, wall)
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(0, -1), edge_type)
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(0, 1), edge_type)
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(-1, 0), edge_type)
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(1, 0), edge_type)
    

    # Register in walls_to_tile
    #walls_to_tile[wall] = tile_pos
    emit_signal("wall_spawned", wall)

func spawn_left_wall(tile_pos: Vector2i, atlas_coords: Vector2i) -> void:
    var wall_edge = WALL_EDGE_SCENE.instantiate()

    # convert tile -> world
    var world_pos = grid_service.tile_to_world(tile_pos)
    wall_edge.position = world_pos
    wall_edge.current_tile = tile_pos
    var frame = atlas_coords.y * 8 + atlas_coords.x
    wall_edge.call_deferred("set_frame", frame)


    # Add to scene tree
    get_node("../../Containers/Walls").add_child(wall_edge)

    # Register in occupancy
    var edge_type = ATLAS_COORDS_TO_EDGE_TYPE[atlas_coords]
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(-1, 0), edge_type)

    # Register in walls_to_tile
    #walls_to_tile[wall] = tile_pos
    emit_signal("wall_spawned", wall_edge)


func spawn_right_wall(tile_pos: Vector2i, atlas_coords: Vector2i) -> void:
    var wall_edge = WALL_EDGE_SCENE.instantiate()

    # convert tile -> world
    var world_pos = grid_service.tile_to_world(tile_pos)
    wall_edge.position = world_pos
    wall_edge.current_tile = tile_pos
    var frame = atlas_coords.y * 8 + atlas_coords.x
    wall_edge.call_deferred("set_frame", frame)

    # Add to scene tree
    get_node("../../Containers/Walls").add_child(wall_edge)

    # Register in occupancy
    var edge_type = ATLAS_COORDS_TO_EDGE_TYPE[atlas_coords]
    edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(0, -1), edge_type)

    # Register in walls_to_tile
    #walls_to_tile[wall] = tile_pos
    emit_signal("wall_spawned", wall_edge)


func apply_damage_to_wall(wall: Wall, amount: int):
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
