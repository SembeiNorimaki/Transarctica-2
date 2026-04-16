extends Node2D
class_name CombatScene

# Managers
@onready var unit_manager = $Managers/UnitManager
@onready var building_manager = $Managers/BuildingManager
@onready var wall_manager = $Managers/WallManager
@onready var turn_manager = $Managers/TurnManager
@onready var selection_manager = $Managers/SelectionManager
@onready var pod_manager = $Managers/PodManager
@onready var horizontal_train_manager = $Managers/HorizontalTrainManager
@onready var unit_ai_manager = $Managers/UnitAIManager

#Containers
@onready var projectiles_container = $Containers/Projectiles

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
@onready var weapon_service = $Services/WeaponService
@onready var exploration_service = $Services/ExplorationService

# Overlays
@onready var units_overlay = $Overlays/UnitsOverlay
@onready var buildings_overlay = $Overlays/BuildingsOverlay
@onready var walls_overlay = $Overlays/WallsOverlay
@onready var roads_overlay = $Overlays/RoadsOverlay
@onready var paths_overlay = $Overlays/PathsOverlay
@onready var mouse_hover_overlay = $Overlays/MouseHoverOverlay
@onready var navigation_graph_overlay = $Overlays/NavigationGraphOverlay
@onready var los_overlay = $Overlays/LOSOverlay

# Map 
@onready var map_root = $MapRoot
@onready var exploration_layer = $MapRoot/ExplorationLayer

# Input State Machine
@onready var state_machine = $CombatStateMachine

# Labels
@onready var state_label = $Labels/StateLabel
@onready var turn_label = $Labels/TurnLabel
@onready var mouse_label = $Labels/MouseLabel
@onready var camera_label = $Labels/CameraLabel

# Cursor
@onready var aim_cursor = $AimCursor

# UI
#@onready var ui_wasd = $UI_WASD

#region initialization
func _ready() -> void:
	_inject_services()
	_register_teams()
	call_deferred("_wire_signals")
	_load_map("level_1")
	navigation_graph_service.build_graph()
	exploration_service.recalculate()
	turn_manager.start_combat()
	
func _inject_services():
	# Managers
	unit_manager.tile_occupancy_service = tile_occupancy_service
	unit_manager.grid_service = grid_service
	building_manager.tile_occupancy_service = tile_occupancy_service
	building_manager.grid_service = grid_service
	wall_manager.tile_occupancy_service = tile_occupancy_service
	wall_manager.edge_occupancy_service = edge_occupancy_service
	wall_manager.grid_service = grid_service
	turn_manager.unit_manager = unit_manager
	turn_manager.unit_ai_manager = unit_ai_manager
	turn_manager.selection_manager = selection_manager
	turn_manager.pod_manager = pod_manager
	pod_manager.tile_occupancy_service = tile_occupancy_service
	pod_manager.grid_service = grid_service
	horizontal_train_manager.tile_occupancy_service = tile_occupancy_service
	horizontal_train_manager.grid_service = grid_service
	unit_ai_manager.unit_manager = unit_manager

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
	los_overlay.grid_service = grid_service

	# Services
	grid_service.camera_controller = camera_controller
	pathfinding_service.tile_occupancy_service = tile_occupancy_service
	pathfinding_service.terrain_service = terrain_service
	pathfinding_service.road_service = road_service
	pathfinding_service.navigation_graph_service = navigation_graph_service
	navigation_graph_service.grid_service = grid_service
	navigation_graph_service.terrain_service = terrain_service
	navigation_graph_service.tile_occupancy_service = tile_occupancy_service
	navigation_graph_service.edge_occupancy_service = edge_occupancy_service
	
	los_service.tile_occupancy_service = tile_occupancy_service
	los_service.edge_occupancy_service = edge_occupancy_service
	los_service.los_overlay = los_overlay
	
	weapon_service.los_service = los_service
	weapon_service.grid_service = grid_service
	weapon_service.projectiles_container = projectiles_container

	exploration_service.grid_service = grid_service
	exploration_service.exploration_layer = exploration_layer
	exploration_service.los_service = los_service
	exploration_service.unit_manager = unit_manager

	camera_controller.grid_service = grid_service

func _register_teams():
	turn_manager.register_team("Player")
	turn_manager.register_team("Enemy")

func _wire_signals():
	#print("Wiring signals")
	unit_manager.connect("unit_spawned", units_overlay.redraw)
	unit_manager.connect("unit_tile_changed", units_overlay.update)
	unit_manager.connect("unit_tile_changed", paths_overlay.update)
	unit_manager.connect("unit_removed", units_overlay.redraw)
	unit_manager.connect("unit_reached_destination", _unit_reached_destination)
	unit_manager.connect("unit_changed_orientation", _unit_changed_orientation)
	unit_manager.connect("unit_changed_tile", _unit_changed_tile)


	building_manager.connect("building_spawned", buildings_overlay.redraw)
	building_manager.connect("building_removed", buildings_overlay.redraw)

	wall_manager.connect("wall_spawned", walls_overlay.redraw)
	wall_manager.connect("wall_removed", walls_overlay.redraw)

	# ui_wasd.connect("move_vector_changed", unit_manager.on_move_vector_changed)
	# ui_wasd.connect("aim_pressed", unit_manager.on_aim_pressed)
	# ui_wasd.connect("aim_released", unit_manager.on_aim_released)

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
	map_root.move_child(new_map, 0)

	# Set tilesize to grid service and tile occupancy service
	var tile_size = new_map.get_node("Terrain").tile_set.tile_size
	grid_service.set_tile_size(tile_size)
	tile_occupancy_service.tile_size = tile_size

	grid_service.map_size = new_map.get_node("Terrain").get_used_rect().size
	#print("Map size %s" % grid_service.map_size)

	# Spawn units, buildings, walls, and roads
	
	_spawn_units_from_map(new_map.get_node("Units"))
	_spawn_buildings_from_map(new_map.get_node("Buildings"))
	_spawn_walls_from_map(new_map.get_node("Walls"))
	#_spawn_roads_from_map(new_map.get_node("Roads"))
	#_spawn_pods_from_map(new_map.get_node("Pods"), new_map.get_node("PatrolPoints"))
	#_assign_units_to_pods(new_map.get_node("Pods"), tile_occupancy_service)

	#_spawn_train(Vector2i(6, 7))

	#_load_patrol_points_from_map(new_map.get_node("PatrolPoints"), Vector2i(6, 7))

	
	#building_manager.spawn_buildings_from_map(map_instance.buildings)
	#wall_manager.spawn_walls_from_map(map_instance.walls)
	#road_service.spawn_roads_from_map(map_instance.roads)

func _load_patrol_points_from_map(patrol_tilemap: TileMapLayer, starting_tile: Vector2i) -> Array[Vector2i]:
	var atlas_coords_to_tile_delta: Dictionary[Vector2i, Vector2i] = {
		Vector2i(0, 0): Vector2i(1, -1), # NE
		Vector2i(1, 0): Vector2i(-1, 1), # SW
		Vector2i(2, 0): Vector2i(-1, -1), # NW
		Vector2i(3, 0): Vector2i(1, 1), # SE
		Vector2i(4, 0): Vector2i(0, -1), # N
		Vector2i(5, 0): Vector2i(0, 1), # S
		Vector2i(6, 0): Vector2i(-1, 0), # W
		Vector2i(7, 0): Vector2i(1, 0), # E
	}

	#print(patrol_tilemap.get_used_cells())
	var points: Array[Vector2i] = [starting_tile]
	var tile: Vector2i = starting_tile
	var next_tile = Vector2i(-1, -1)
	var idx = 0
	while idx < 100:
		var atlas_coords = patrol_tilemap.get_cell_atlas_coords(tile)
		var delta: Vector2i = atlas_coords_to_tile_delta.get(atlas_coords)
		#print("Tile: %s, Atlas coords: %s, Delta: %s" % [tile, atlas_coords, delta])
		next_tile = tile + delta
		points.append(next_tile)
		tile = next_tile
		if next_tile == starting_tile:
			break
		idx += 1

	#print("Patrol points: %s" % points)
	return points

# Must be called after loading units from map
func _assign_units_to_pods(pods_tilemap: TileMapLayer, tile_occupancy_service: TileOccupancyService):
	for tile in pods_tilemap.get_used_cells():
		var atlas_coords = pods_tilemap.get_cell_atlas_coords(tile)
		if atlas_coords.y != 1: # only atlascords.y == 1 are valid unit assignations
			continue
		var pod_id = "p%s" % atlas_coords.x
		var units: Array[Unit] = tile_occupancy_service.get_units(tile)
		pod_manager.add_units_to_pod(pod_id, units)
		# print("Assigning unit %s to pod %s" % [units[0].id, pod_id])
	

func _spawn_train(initial_tile: Vector2i):
	horizontal_train_manager.spawn_train(initial_tile)


func _spawn_units_from_map(units_tilemap: TileMapLayer) -> void:
	for tile in units_tilemap.get_used_cells():
		var atlas_coords = units_tilemap.get_cell_atlas_coords(tile)
		var source_id = units_tilemap.get_cell_source_id(tile)
		var unit_type = UnitTypes.get_unit_type_from_atlas_coords(atlas_coords)
		var owner_id = UnitTypes.get_owner_id_from_atlas_coords(atlas_coords)
		unit_manager.spawn_unit(tile, unit_type, owner_id)

		# Remove the placeholder tile
		units_tilemap.erase_cell(tile)

func _spawn_pods_from_map(pods_tilemap: TileMapLayer, patrol_tilemap: TileMapLayer) -> void:
	for tile in pods_tilemap.get_used_cells():
		var atlas_coords = pods_tilemap.get_cell_atlas_coords(tile)
		if atlas_coords.y != 0: # only atlascords.y == 0 are valid pod locations
			continue

		# load the patrol route for this pod:
		var patrol_route = _load_patrol_points_from_map(patrol_tilemap, tile)

		var id = "p%s" % atlas_coords.x
		pod_manager.spawn_pod(id, tile, patrol_route)

		# Remove the placeholder tile
		pods_tilemap.erase_cell(tile)

	
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
		var atlas_coords = full_tilemap.get_cell_atlas_coords(tile)
		wall_manager.spawn_full_wall(tile, atlas_coords)
		# Remove the placeholder tile
		full_tilemap.erase_cell(tile)

	for tile in left_tilemap.get_used_cells():
		var atlas_coords = left_tilemap.get_cell_atlas_coords(tile)
		wall_manager.spawn_left_wall(tile, atlas_coords)
		# Remove the placeholder tile
		left_tilemap.erase_cell(tile)

	for tile in right_tilemap.get_used_cells():
		var atlas_coords = right_tilemap.get_cell_atlas_coords(tile)
		wall_manager.spawn_right_wall(tile, atlas_coords)
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
		var mouse_pos = get_local_mouse_position()
		var tile = grid_service.world_to_tile(mouse_pos)
		#print("Mouse pos: %s, tile: %s" % [mouse_pos, tile])
		state_machine.current_state.handle_click(tile, event.button_index)
	if event is InputEventKey and event.pressed and not event.echo:
		state_machine.current_state.handle_key(event)

	if event is InputEventMouseMotion:
		update_mouse_label()

func _handle_global_input(event: InputEvent) -> bool:
	if event.is_action_pressed("e"):
		turn_manager.finish_turn()
		return true
	return false

#region Labels
func update_state_label(state_name: String) -> void:
	if state_label:
		state_label.text = "State: %s" % state_name

func update_turn_label(turn_id: String) -> void:
	if turn_label:
		turn_label.text = "Turn: %s" % turn_id

func update_mouse_label():
	mouse_label.text = "Mouse: %s, tile: %s" % [round(get_local_mouse_position()), grid_service.world_to_tile(get_local_mouse_position())]

func update_camera_label(val):
	camera_label.text = "Camera: Offset %s, Zoom %s" % [camera_controller.offset, camera_controller.zoom]


func update_labels():
	#State Machines:
	state_label.text = "Combat: %s   Turn: %s" % [state_machine.current_state.name, turn_manager.turn_state_machine.current_state.name]
	

#endregion


#region unit signal handling

func _unit_reached_destination(unit):
	state_machine.set_state("UnitSelectedState", {"selected_unit": unit})

func _unit_changed_orientation(unit, new_orientation):
	exploration_service.on_unit_orientation_changed(unit, new_orientation)

func _unit_changed_tile(unit, new_tile):
	exploration_service.on_unit_tile_changed(unit, new_tile)

#endregion

func select_next_unit():
	var next_unit = unit_manager.get_next_unit_by_team("Player")
	if next_unit:
		state_machine.set_state("UnitSelectedState", {"selected_unit": next_unit})

func register_units_in_turn_manager():
	for unit in unit_manager.get_player_units():
		turn_manager.register_unit("player", unit)
	for unit in unit_manager.get_enemy_units():
		turn_manager.register_unit("enemy", unit)
		
func _on_bullet_requested(from, to, scene):
	var bullet = scene.instantiate()
	projectiles_container.add_child(bullet)
	bullet.fire(from, to)

func on_bullet_hit(position):
	#convert position to tile
	var tile_ = grid_service.world_to_tile(position)
	print("Combat scene on bullet hit ", position, "  ", tile_)
	var entities_ = tile_occupancy_service.get_entities(tile_)
	print("Entities found in tile: ", entities_)
	if entities_.size() > 0:
		if entities_[0] is Unit:
			unit_manager.apply_damage_to_unit(entities_[0], 10)
		else:
			wall_manager.apply_damage_to_wall(entities_[0], 10)

func _process(delta: float) -> void:
	$Labels/FPSLabel.text = "FPS: %s" % Engine.get_frames_per_second()
	update_camera_label(get_viewport().canvas_transform)
	update_labels()


func set_cursor(cursor_name: String) -> void:
	if cursor_name == "aim":
		aim_cursor.visible = true
	else:
		aim_cursor.visible = false
