extends Node2D
class_name CombatScene

# Managers
@onready var unit_manager: UnitManager = $Managers/UnitManager
@onready var building_manager: BuildingManager = $Managers/BuildingManager
@onready var wall_manager: WallManager = $Managers/WallManager
@onready var turn_manager: TurnManager = $Managers/TurnManager
@onready var selection_manager: SelectionManager = $Managers/SelectionManager
@onready var pod_manager: PodManager = $Managers/PodManager
@onready var horizontal_train_manager: HorizontalTrainManager = $Managers/HorizontalTrainManager
@onready var faction_ai: FactionAI = $Managers/FactionAI
@onready var pod_ai_manager: PodAIManager = $Managers/PodAIManager

#Containers
@onready var projectiles_container: Node2D = $Containers/Projectiles
@onready var train_container: Node2D = $Containers/Trains
@onready var train_resource_container: TrainResourceContainer = $Containers/TrainResourceContainer

# Controllers
@onready var camera_controller: CameraController = $Controllers/CameraController

# Services
@onready var road_service: RoadService = $Services/RoadService
@onready var grid_service: GridService = $Services/GridService
@onready var tile_occupancy_service: TileOccupancyService = $Services/TileOccupancyService
@onready var pathfinding_service: PathfindingService = $Services/PathfindingService
@onready var terrain_service: TerrainService = $Services/TerrainService
@onready var navigation_graph_service: NavigationGraphService = $Services/NavigationGraphService
@onready var edge_occupancy_service: EdgeOccupancyService = $Services/EdgeOccupancyService
@onready var los_service: LOSService = $Services/LOSService
@onready var weapon_service: WeaponService = $Services/WeaponService
@onready var exploration_service: ExplorationService = $Services/ExplorationService
@onready var cover_service: CoverService = $Services/CoverService

# Overlays
@onready var units_overlay: Node2D = $Overlays/UnitsOverlay
@onready var buildings_overlay: Node2D = $Overlays/BuildingsOverlay
@onready var walls_overlay: Node2D = $Overlays/WallsOverlay
@onready var roads_overlay: Node2D = $Overlays/RoadsOverlay
@onready var paths_overlay: Node2D = $Overlays/PathsOverlay
@onready var mouse_hover_overlay: Node2D = $Overlays/MouseHoverOverlay
@onready var navigation_graph_overlay: Node2D = $Overlays/NavigationGraphOverlay
@onready var los_overlay: Node2D = $Overlays/LOSOverlay
@onready var fov_overlay: Node2D = $Overlays/FOVOverlay
@onready var reachable_tiles_overlay: Node2D = $Overlays/ReachableTilesOverlay
@onready var cover_overlay: Node2D = $Overlays/CoverOverlay


# Map 
@onready var map_root: Node2D = $MapRoot
@onready var exploration_layer: ExplorationLayer = $MapRoot/ExplorationLayer

# Input State Machine
@onready var state_machine: StateMachine = $CombatStateMachine

# Labels
@onready var state_label: Label = $Labels/StateLabel
@onready var turn_label: Label = $Labels/TurnLabel
@onready var mouse_label: Label = $Labels/MouseLabel
@onready var camera_label: Label = $Labels/CameraLabel

# Cursor
@onready var aim_cursor: Sprite2D = $AimCursor

# UI
#@onready var ui_wasd = $UI_WASD

var is_intro := true
var is_outro := false
var horizontal_train: HorizontalTrain = null

var train_initial_tile := Vector2(10, 10)
var camera_initial_tile := Vector2i(25, 0)

#region initialization
func _ready() -> void:
	_inject_services()
	_register_teams()
	call_deferred("_wire_signals")
	_load_map("level_1")

	# this precomputation should be done in _load_map
	navigation_graph_service.build_graph(map_root.get_node("Level1").get_node("Terrain"))
	cover_service.build_cover_map(navigation_graph_service.nodes.keys())



	camera_controller.center_at_tile(camera_initial_tile)
	camera_controller.set_zoom(1.0)
	
	#exploration_service.recalculate()
	#turn_manager.start_combat()
	if get_tree().current_scene == self:
		print("Combat is running standalone")
	else:
		print("Combat was instantiated by SceneManager")
		
	call_deferred("initialize")
	
func initialize():
	print("Initializing combat")
	load_train_from_game_state()

	unload_soldier_from_wagon(1)


func _inject_services():
	# Managers
	unit_manager.tile_occupancy_service = tile_occupancy_service
	unit_manager.grid_service = grid_service
	unit_manager.camera_controller = camera_controller
	unit_manager.navigation_graph_service = navigation_graph_service
	building_manager.tile_occupancy_service = tile_occupancy_service
	building_manager.grid_service = grid_service
	wall_manager.tile_occupancy_service = tile_occupancy_service
	wall_manager.edge_occupancy_service = edge_occupancy_service
	wall_manager.grid_service = grid_service
	turn_manager.unit_manager = unit_manager
	turn_manager.faction_ai = faction_ai
	turn_manager.pod_ai_manager = pod_ai_manager
	turn_manager.selection_manager = selection_manager
	turn_manager.pod_manager = pod_manager
	pod_manager.tile_occupancy_service = tile_occupancy_service
	pod_manager.grid_service = grid_service
	horizontal_train_manager.tile_occupancy_service = tile_occupancy_service
	horizontal_train_manager.grid_service = grid_service
	horizontal_train_manager.train_resource_container = train_resource_container
	faction_ai.unit_manager = unit_manager
	pod_ai_manager.pod_manager = pod_manager
	pod_ai_manager.unit_manager = unit_manager
	

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
	fov_overlay.grid_service = grid_service
	reachable_tiles_overlay.grid_service = grid_service
	cover_overlay.grid_service = grid_service

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
	navigation_graph_service.reachable_tiles_overlay = reachable_tiles_overlay
	cover_service.edge_occupancy_service = edge_occupancy_service
	cover_service.cover_overlay = cover_overlay
	
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
	exploration_service.fov_overlay = fov_overlay

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
	unit_manager.connect("unit_tile_changed", _unit_changed_tile)


	building_manager.connect("building_spawned", buildings_overlay.redraw)
	building_manager.connect("building_removed", buildings_overlay.redraw)

	wall_manager.connect("wall_spawned", walls_overlay.redraw)
	wall_manager.connect("wall_removed", walls_overlay.redraw)

	# combat_hud.reverse_pressed.connect()

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
	print("Map size %s" % grid_service.map_size)

	# Spawn units, buildings, walls, and roads
	
	_spawn_units_from_map(new_map.get_node("Units"))
	_spawn_buildings_from_map(new_map.get_node("Buildings"))
	_spawn_walls_from_map(new_map.get_node("Walls"))
	#_spawn_roads_from_map(new_map.get_node("Roads"))
	_spawn_pods_from_map(new_map.get_node("Pods"), new_map.get_node("PatrolPoints"))
	_assign_units_to_pods(new_map.get_node("Pods"), tile_occupancy_service)

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
	print("Assign units to pods:")
	for tile in pods_tilemap.get_used_cells():
		#print("  Rile %s" % tile)
		var atlas_coords = pods_tilemap.get_cell_atlas_coords(tile)
		#if atlas_coords.y != 1: # only atlascords.y == 1 are valid unit assignations
		#	continue
		var pod_id = "p%s" % atlas_coords.x
		var pod_tile = pod_manager.get_pod_tile(pod_manager.pods_by_id[pod_id])
		# only one unit can be in a tile, so although it returns an array, only units[0] is used
		var units: Array[Unit] = tile_occupancy_service.get_units(tile)
		print("Units0: ", units[0])
		print("Units[0].CT: ", units[0].current_tile)
		print("PodTile: ", pod_tile)

		var unit_formation_offset = units[0].current_tile - pod_tile
		pod_manager.add_unit_to_pod(pod_id, units[0], unit_formation_offset)
		# print("Assigning unit %s to pod %s" % [units[0].id, pod_id])
	
func load_train_from_game_state():
	print("Loading horizontal train from game state")
	horizontal_train = horizontal_train_manager.spawn_train(train_initial_tile, "Player")
	horizontal_train.set_speed(horizontal_train.max_speed)
	train_container.add_child(horizontal_train)
	print("Spawned horizontal train at tile: %s" % train_initial_tile)

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
		#pods_tilemap.erase_cell(tile)

	
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

#region process
func _process(delta: float) -> void:
	update_labels()
	if is_intro:
		_process_intro()
	elif is_outro:
		_process_outro()

func _process_intro():
	if horizontal_train.global_position.x > 500:
		horizontal_train.gear_down()
		is_intro = false

func _process_outro():
	if horizontal_train.global_position.x > 2000:
		SceneManager.leave_combat()
#endregion

# check global inputs, mouse clicks and key presses. Passes mouse clicks and key presses to the state machine
func _unhandled_input(event: InputEvent) -> void:
	if _handle_global_input(event):
		return

	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_local_mouse_position()

		# Check if we clicked a wagon
		var clicked_wagon_id = horizontal_train_manager.check_wagon_click(mouse_pos)
		if clicked_wagon_id != -1:
			_handle_wagon_click(clicked_wagon_id)
			return

			
		var tile = grid_service.world_to_tile(mouse_pos)
		_handle_tile_click(tile, event.button_index)
			
	if event is InputEventKey and event.pressed and not event.echo:
		state_machine.current_state.handle_key(event)

func _handle_wagon_click(wagon_id: int) -> void:
	print("Wagon clicked: %s" % wagon_id)
	var wagon = horizontal_train_manager.player_train.wagons[wagon_id]
	wagon.on_click()

func _handle_tile_click(tile: Vector2i, button_index: int) -> void:
	print("Tile clicked %s" % tile)
	state_machine.current_state.handle_click(tile, button_index)

func _handle_key_press(event: InputEventKey) -> void:
	state_machine.current_state.handle_key(event)

# global inputs:
# e: finish turn
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

func update_camera_label():
	camera_label.text = "Camera: Offset %s, Zoom %s" % [camera_controller.offset, camera_controller.zoom]


func update_labels():
	#State Machines:
	state_label.text = "Combat: %s   Turn: %s" % [state_machine.current_state.name, turn_manager.turn_state_machine.current_state.name]
	update_camera_label()
	update_mouse_label()
	

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

func unload_soldier_from_wagon(wagon_id: int) -> void:
	var tile = Vector2i(32, 0)
	unit_manager.spawn_unit(tile, "liquidator", "Player")

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

	
func set_cursor(cursor_name: String) -> void:
	if cursor_name == "aim":
		aim_cursor.visible = true
	elif cursor_name == "":
		aim_cursor.visible = false
