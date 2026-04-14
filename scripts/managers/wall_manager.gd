extends Node
class_name WallManager

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var edge_occupancy_service: EdgeOccupancyService
var grid_service: GridService

var walls_to_tile := {} # Dict of walls -> tile_position

const WALL_SCENE = preload("res://scenes/entities/walls/wall.tscn")
const WALL_EDGE_SCENE = preload("res://scenes/entities/walls/wall_edge.tscn")

signal wall_spawned(wall)

func _ready() -> void:
	pass


func spawn_full_wall(tile_pos: Vector2i) -> void:
	var wall = WALL_SCENE.instantiate()

	# convert tile -> world
	var world_pos = grid_service.tile_to_world(tile_pos)
	wall.position = world_pos
	wall.current_tile = tile_pos
	wall.call_deferred("set_frame", 1)

	# Add to scene tree
	get_node("../../Containers/Walls").add_child(wall)

	# Register in occupancy
	# Register in occupancy
	
	tile_occupancy_service.register(tile_pos, wall)
	

	# Register in walls_to_tile
	#walls_to_tile[wall] = tile_pos
	emit_signal("wall_spawned", wall)

func spawn_left_wall(tile_pos: Vector2i) -> void:
	var wall_edge = WALL_EDGE_SCENE.instantiate()

	# convert tile -> world
	var world_pos = grid_service.tile_to_world(tile_pos)
	wall_edge.position = world_pos
	wall_edge.current_tile = tile_pos
	wall_edge.call_deferred("set_frame", 1)

	# Add to scene tree
	get_node("../../Containers/Walls").add_child(wall_edge)

	# Register in occupancy
	edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(-1, 0))

	# Register in walls_to_tile
	#walls_to_tile[wall] = tile_pos
	emit_signal("wall_spawned", wall_edge)


func spawn_right_wall(tile_pos: Vector2i) -> void:
	var wall_edge = WALL_EDGE_SCENE.instantiate()

	# convert tile -> world
	var world_pos = grid_service.tile_to_world(tile_pos)
	wall_edge.position = world_pos
	wall_edge.current_tile = tile_pos
	wall_edge.call_deferred("set_frame", 0)

	# Add to scene tree
	get_node("../../Containers/Walls").add_child(wall_edge)

	# Register in occupancy
	edge_occupancy_service.register(tile_pos, tile_pos + Vector2i(0, -1))

	# Register in walls_to_tile
	#walls_to_tile[wall] = tile_pos
	emit_signal("wall_spawned", wall_edge)

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
