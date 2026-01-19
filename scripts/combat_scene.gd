extends Node2D

# Managers
@onready var unit_manager = $Managers/UnitManager
@onready var building_manager = $Managers/BuildingManager
@onready var wall_manager = $Managers/WallManager
@onready var turn_manager = $Managers/TurnManager

@onready var selection_manager = $Managers/SelectionManager

# Controllers
@onready var camera_controller = $Controllers/CameraController

# Services
@onready var road_service = $Services/RoadService
@onready var grid_service = $Services/GridService
@onready var tile_occupancy_service = $Services/TileOccupancyService
@onready var pathfinding_service = $Services/PathfindingService
@onready var terrain_service = $Services/TerrainService
@onready var navigation_graph_service = $Services/NavigationGraphService
@onready var edge_occupancy_service = $Services/EdgeOccupancyService
@onready var los_service = $Services/LOSService

# Overlays
@onready var units_overlay = $Overlays/UnitsOverlay
@onready var buildings_overlay = $Overlays/BuildingsOverlay
@onready var walls_overlay = $Overlays/WallsOverlay
@onready var roads_overlay = $Overlays/RoadsOverlay
@onready var paths_overlay = $Overlays/PathsOverlay
@onready var mouse_hover_overlay = $Overlays/MouseHoverOverlay
@onready var navigation_graph_overlay = $Overlays/NavigationGraphOverlay

# Map 
@onready var map_root = $MapRoot

# Input State Machine
@onready var state_machine = $CombatStateMachine

# Labels
@onready var state_label = $Labels/StateLabel
@onready var turn_label = $Labels/TurnLabel


#region initialization
func _ready() -> void:
	_inject_services()
	_register_teams()
	call_deferred("_wire_signals")
	_load_map("level_1")
	navigation_graph_service.build_graph()

	turn_manager.start_combat()

func _inject_services():
	# State machines
	state_machine.states["AimingState"].los_service = los_service
	

	# Managers
	unit_manager.tile_occupancy_service = tile_occupancy_service
	unit_manager.grid_service = grid_service
	building_manager.tile_occupancy_service = tile_occupancy_service
	building_manager.grid_service = grid_service
	wall_manager.tile_occupancy_service = tile_occupancy_service
	wall_manager.edge_occupancy_service = edge_occupancy_service
	wall_manager.grid_service = grid_service
	turn_manager.unit_manager = unit_manager
	turn_manager.selection_manager = selection_manager

	# Overlays
	units_overlay.grid_service = grid_service
	units_overlay.tile_occupancy_service = tile_occupancy_service
	buildings_overlay.grid_service = grid_service
	buildings_overlay.tile_occupancy_service = tile_occupancy_service
	walls_overlay.grid_service = grid_service
	walls_overlay.tile_occupancy_service = tile_occupancy_service
	walls_overlay.edge_occupancy_service = edge_occupancy_service
	roads_overlay.road_service = road_service
	paths_overlay.grid_service = grid_service
	mouse_hover_overlay.grid_service = grid_service
	navigation_graph_overlay.navigation_graph_service = navigation_graph_service
	navigation_graph_overlay.grid_service = grid_service

	# Services
	pathfinding_service.tile_occupancy_service = tile_occupancy_service
	pathfinding_service.terrain_service = terrain_service
	pathfinding_service.road_service = road_service
	pathfinding_service.navigation_graph_service = navigation_graph_service
	navigation_graph_service.grid_service = grid_service
	navigation_graph_service.terrain_service = terrain_service
	navigation_graph_service.tile_occupancy_service = tile_occupancy_service
	navigation_graph_service.edge_occupancy_service = edge_occupancy_service
	los_service.tile_occupancy_service = tile_occupancy_service


func _register_teams():
	turn_manager.register_team("player")
	turn_manager.register_team("enemy")

func _wire_signals():
	print("Wiring signals")
	camera_controller.connect("camera_moved", grid_service.update_camera_transform)

	unit_manager.connect("unit_spawned", units_overlay.redraw)
	unit_manager.connect("unit_tile_changed", units_overlay.update)
	unit_manager.connect("unit_tile_changed", paths_overlay.update)
	unit_manager.connect("unit_removed", units_overlay.redraw)
	unit_manager.connect("unit_reached_destination", _unit_reached_destination)

	building_manager.connect("building_spawned", buildings_overlay.redraw)
	building_manager.connect("building_removed", buildings_overlay.redraw)

	wall_manager.connect("wall_spawned", walls_overlay.redraw)
	wall_manager.connect("wall_removed", walls_overlay.redraw)

#endregion

#region Map Loading
func _load_map(map_name: String) -> void:
	# The default map is already in the scene
	#if map_name == "level_1":
	#	return
	# For other maps, swap the map
	var map_path = "res://scenes/maps/%s.tscn" % map_name
	if not ResourceLoader.exists(map_path):
		push_error("Map not found for map: %s at path: %s" % [map_name, map_path])
	# remove existing map
	if get_node("MapRoot").get_child_count() > 0:
		var existing_map = get_node("MapRoot").get_child(0)
		map_root.remove_child(existing_map)
		existing_map.free()
	# load new map
	var new_map = load(map_path).instantiate()
	map_root.add_child(new_map)

	# Set tilesize to grid service and tile occupancy service
	var tile_size = new_map.get_node("Terrain").tile_set.tile_size
	grid_service.tile_size = tile_size
	grid_service.map_origin = tile_size / 2
	tile_occupancy_service.tile_size = tile_size

	grid_service.map_size = new_map.get_node("Terrain").get_used_rect().size
	print("Map size %s" % grid_service.map_size)

	# Spawn units, buildings, walls, and roads
	_load_patrol_points_from_map(new_map.get_node("PatrolPoints"))
	_spawn_units_from_map(new_map.get_node("Units"))
	_spawn_buildings_from_map(new_map.get_node("Buildings"))
	_spawn_walls_from_map(new_map.get_node("Walls"))
	_spawn_roads_from_map(new_map.get_node("Roads"))


	grid_service.test()
	
	#building_manager.spawn_buildings_from_map(map_instance.buildings)
	#wall_manager.spawn_walls_from_map(map_instance.walls)
	#road_service.spawn_roads_from_map(map_instance.roads)

func _load_patrol_points_from_map(patrol_tilemap: TileMapLayer) -> void:
	var atlas_coords_to_tile_delta = {
		Vector2i(0, 0): Vector2i(1, -1), # E
		Vector2i(1, 0): Vector2i(-1, 1), # W
		Vector2i(2, 0): Vector2i(-1, -1), # N
		Vector2i(3, 0): Vector2i(1, 1), # S
		Vector2i(4, 0): Vector2i(0, -1), # NE
		Vector2i(5, 0): Vector2i(0, 1), # SW
		Vector2i(6, 0): Vector2i(-1, 0), # NW
		Vector2i(7, 0): Vector2i(0, 0), # SE
	}

	print(patrol_tilemap.get_used_cells())
	var points := []


	if patrol_tilemap.get_used_cells().size() == 0:
		return
	var tile = patrol_tilemap.get_used_cells()[0]
	points.append(tile)
	var next_tile = Vector2i(-1, -1)
	while true:
		var atlas_coords = patrol_tilemap.get_cell_atlas_coords(tile)
		var delta = atlas_coords_to_tile_delta.get(atlas_coords)
		next_tile = tile + delta
		if next_tile == tile:
			break
		points.append(next_tile)
		tile = next_tile
	print("Patrol points: %s" % points)

func _spawn_units_from_map(units_tilemap: TileMapLayer) -> void:
	for tile in units_tilemap.get_used_cells():
		var atlas_coords = units_tilemap.get_cell_atlas_coords(tile)
		var unit_type = UnitTypes.get_unit_type_from_atlas_coords(atlas_coords)
		var owner_id = UnitTypes.get_owner_id_from_atlas_coords(atlas_coords)

		print("***Spawning unit %s of owner %s at tile %s" % [unit_type, owner_id, tile])
		unit_manager.spawn_unit(tile, unit_type, owner_id)

		# Remove the placeholder tile
		units_tilemap.erase_cell(tile)

func _spawn_buildings_from_map(buildings_tilemap: TileMapLayer) -> void:
	for tile in buildings_tilemap.get_used_cells():
		var atlas_coords = buildings_tilemap.get_cell_atlas_coords(tile)
		var building_type = BuildingTypes.get_building_type_from_atlas_coords(atlas_coords)
		var owner_id = 0
		building_manager.spawn_building(tile, building_type, owner_id)

		# Remove the placeholder tile
		buildings_tilemap.erase_cell(tile)

func _spawn_walls_from_map(walls_container: Node2D) -> void:
	# Walls are divided in 3 tilesets: Full, Left & Right
	var full_tilemap: TileMapLayer = walls_container.get_node("Full")
	var left_tilemap: TileMapLayer = walls_container.get_node("Left")
	var right_tilemap: TileMapLayer = walls_container.get_node("Right")

	for tile in full_tilemap.get_used_cells():
		wall_manager.spawn_full_wall(tile)
		# Remove the placeholder tile
		full_tilemap.erase_cell(tile)

	for tile in left_tilemap.get_used_cells():
		wall_manager.spawn_left_wall(tile)
		# Remove the placeholder tile
		left_tilemap.erase_cell(tile)

	for tile in right_tilemap.get_used_cells():
		wall_manager.spawn_right_wall(tile)
		# Remove the placeholder tile
		right_tilemap.erase_cell(tile)

func _spawn_roads_from_map(roads_tilemap: TileMapLayer) -> void:
	for tile in roads_tilemap.get_used_cells():
		road_service.spawn_road(tile)
#endregion


func _unhandled_input(event: InputEvent) -> void:
	if _handle_global_input(event):
		return

	if event is InputEventMouseButton and event.pressed:
		var world = grid_service.screen_to_world(event.position)
		var tile = grid_service.world_to_tile(world)
		print(event.position, world, tile)
		state_machine.current_state.handle_click(tile, event.button_index)
	if event is InputEventKey and event.pressed and not event.echo:
		state_machine.current_state.handle_key(event)

func _handle_global_input(event: InputEvent) -> bool:
	if event.is_action_pressed("e"):
		turn_manager.finish_turn()
		return true
	return false

func update_state_label(state_name: String) -> void:
	if state_label:
		state_label.text = "State: %s" % state_name

func update_turn_label(turn_id: String) -> void:
	if turn_label:
		turn_label.text = "Turn: %s" % turn_id

func _unit_reached_destination(unit):
	state_machine.set_state("IdleState")

func select_next_unit():
	var next_unit = unit_manager.get_next_unit()
	if next_unit:
		state_machine.set_state("UnitSelectedState", {"selected_unit": next_unit})

func register_units_in_turn_manager():
	for unit in unit_manager.get_player_units():
		turn_manager.register_unit("player", unit)
	for unit in unit_manager.get_enemy_units():
		turn_manager.register_unit("enemy", unit)
		

func _process(delta: float) -> void:
	$Labels/FPSLabel.text = "FPS: %s" % Engine.get_frames_per_second()
