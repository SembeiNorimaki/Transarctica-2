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
@onready var wagon_manager: WagonManager = $Managers/WagonManager
@onready var faction_ai: FactionAI = $Managers/FactionAI
@onready var pod_ai_manager: PodAIManager = $Managers/PodAIManager

#Containers
@onready var projectiles_container: Node2D = $Containers/Projectiles
@onready var train_container: Node2D = $Containers/Trains
@onready var train_inventory: TrainInventory = $Containers/TrainInventory

# HUD
@onready var master_hud: Control = $CanvasLayer/MasterHUD

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
@onready var accuracy_service: AccuracyService = $Services/AccuracyService

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
@onready var defensiveness_overlay: Node2D = $Overlays/DefensivenessOverlay

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

var is_intro := true
var is_outro := false
var horizontal_train: HorizontalTrain = null

var train_initial_tile := Vector2(10, 10)
var camera_initial_tile := Vector2i(25, 0)

@export var scene_info = {
    "scene_file": "level_1.tscn",
    "node_name": "Level1"
}

# ready, initialize, _inject_services, _wire_signals
#region initialization
func _ready() -> void:
    _inject_services()
    call_deferred("_wire_signals")
    _load_map(scene_info.scene_file)
    
    camera_controller.center_at_tile(camera_initial_tile)
    camera_controller.set_zoom(1.0)
    turn_manager.start_combat()
    
    if get_tree().current_scene == self:
        # print("Combat is running standalone")
        pass
    else:
        # print("Combat was instantiated by SceneManager")
        pass
    call_deferred("initialize")
    
func initialize():
    # print("Initializing combat")
    _load_train()
    #unload_soldier_from_wagon(1)

    # Calculates initial visibility by all player units
    unit_manager.recalculate_all_units_vision()
    unit_manager.recalculate_all_units_seen_enemies()
    _update_enemy_visibility()
    exploration_service.initialize()

    #


func _inject_services():
    # Managers
    unit_manager.tile_occupancy_service = tile_occupancy_service
    unit_manager.grid_service = grid_service
    unit_manager.camera_controller = camera_controller
    unit_manager.navigation_graph_service = navigation_graph_service
    unit_manager.los_service = los_service
    unit_manager.cover_service = cover_service
    unit_manager.weapon_service = weapon_service
    unit_manager.pathfinding_service = pathfinding_service
    unit_manager.defensiveness_overlay = defensiveness_overlay
    unit_manager.fov_overlay = fov_overlay
    unit_manager.paths_overlay = paths_overlay
    unit_manager.accuracy_service = accuracy_service

    building_manager.tile_occupancy_service = tile_occupancy_service
    building_manager.grid_service = grid_service
    wall_manager.tile_occupancy_service = tile_occupancy_service
    wall_manager.edge_occupancy_service = edge_occupancy_service
    wall_manager.grid_service = grid_service
    pod_manager.tile_occupancy_service = tile_occupancy_service
    pod_manager.grid_service = grid_service
    turn_manager.faction_ai = faction_ai
    horizontal_train_manager.tile_occupancy_service = tile_occupancy_service
    horizontal_train_manager.grid_service = grid_service
    horizontal_train_manager.train_inventory = train_inventory
    faction_ai.unit_manager = unit_manager
    pod_ai_manager.pod_manager = pod_manager
    pod_ai_manager.unit_manager = unit_manager

    # HUD
    master_hud.get_node("WagonHUD").wagon_manager = wagon_manager

    # WagonManager
    wagon_manager.horizontal_train_manager = horizontal_train_manager
    wagon_manager.grid_service = grid_service
    wagon_manager.tile_occupancy_service = tile_occupancy_service
    wagon_manager.unit_manager = unit_manager
    
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
    defensiveness_overlay.grid_service = grid_service
    
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
    weapon_service.edge_occupancy_service = edge_occupancy_service
    weapon_service.projectiles_container = projectiles_container

    exploration_service.grid_service = grid_service
    exploration_service.exploration_layer = exploration_layer
    exploration_service.los_service = los_service
    exploration_service.unit_manager = unit_manager
    exploration_service.fov_overlay = fov_overlay

    camera_controller.grid_service = grid_service
    

func _wire_signals():
    #print("Wiring signals")
    unit_manager.connect("unit_spawned", units_overlay.redraw)
    unit_manager.unit_arrived_to_tile.connect(units_overlay.update)
    unit_manager.unit_arrived_to_tile.connect(paths_overlay.update)
    unit_manager.unit_path_started.connect(paths_overlay.show_path_debug)
    unit_manager.unit_arrived_to_tile.connect(exploration_service.on_unit_tile_changed)
    #unit_manager.unit_removed.connect(units_overlay.redraw)
    unit_manager.unit_reached_destination.connect(_unit_reached_destination)
    unit_manager.unit_changed_orientation.connect(_unit_changed_orientation)
    unit_manager.unit_died.connect(_on_unit_died)
    building_manager.building_spawned.connect(buildings_overlay.redraw)
    #building_manager.building_removed.connect(buildings_overlay.redraw)
    wall_manager.wall_spawned.connect(walls_overlay.redraw)
    #wall_manager.wall_removed.connect(walls_overlay.redraw)
    faction_ai.faction_finished.connect(turn_manager._on_faction_finished)

    # combat_hud.reverse_pressed.connect()

    # ui_wasd.connect("move_vector_changed", unit_manager.on_move_vector_changed)
    # ui_wasd.connect("aim_pressed", unit_manager.on_aim_pressed)
    # ui_wasd.connect("aim_released", unit_manager.on_aim_released)

    # WagonManager: refresh WagonHUD after a unit is unloaded
    wagon_manager.unit_unloaded.connect(
        func(wagon_id: int): master_hud.get_node("WagonHUD").setup({"wagon_id": wagon_id})
    )

#endregion

# _load_map, _load_patrol_points, _assign_units_to_pods, load_train,
# _spawn_units, _spawn_pods, _spawn_buildings, _spawn_walls, _spawn_roads, 
#region Map Loading
func _load_map(map_file: String) -> void:
    # The default map is already in the scene
    #if map_name == "level_1":
    #    return
    # For other maps, swap the map
    var map_path = "res://scenes/maps/%s" % map_file
    if not ResourceLoader.exists(map_path):
        push_error("Map not found for map: %s at path: %s" % [map_file, map_path])
        return
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

    _randomize_terrain(new_map.get_node("Terrain"))
    
    _spawn_units(new_map.get_node("Units"))
    _spawn_buildings(new_map.get_node("Buildings"))
    _spawn_walls(new_map.get_node("Walls"))
    #_spawn_roads_from_map(new_map.get_node("Roads"))
    _spawn_pods(new_map.get_node("Pods"), new_map.get_node("PatrolPoints"))
    #_assign_units_to_pods(new_map.get_node("Pods"), tile_occupancy_service)

    #_load_patrol_points_from_map(new_map.get_node("PatrolPoints"), Vector2i(6, 7))

    
    #building_manager.spawn_buildings_from_map(map_instance.buildings)
    #wall_manager.spawn_walls_from_map(map_instance.walls)
    #road_service.spawn_roads_from_map(map_instance.roads)

    # Compute navigation_graph and covers
    navigation_graph_service.build_graph(map_root.get_node("Level1").get_node("Terrain"))
    cover_service.build_cover_map(navigation_graph_service.nodes.keys())


func _randomize_terrain(terrain_tilemap: TileMapLayer):
    var base_tile = Vector2i(0, 0)
    var alternative_prob = 0.1
    var alternative_tiles = {
        Vector2i(8, 0): 2.0,
        Vector2i(9, 0): 1.0,
        Vector2i(4, 1): 2.0,
        Vector2i(5, 1): 2.0,
        Vector2i(5, 0): 1.0,
        Vector2i(6, 0): 1.0,
        Vector2i(7, 0): 1.0
        
    }

    var total_weight = 0.0
    for weight in alternative_tiles.values():
        total_weight += weight

    for cell in terrain_tilemap.get_used_cells():
        var source_id = terrain_tilemap.get_cell_source_id(cell)
        var atlas_coords = terrain_tilemap.get_cell_atlas_coords(cell)

        if atlas_coords != base_tile:
            continue

        if randf() > alternative_prob:
            continue

        var pick = randf() * total_weight
        var chosen_tile = base_tile
        for tile in alternative_tiles.keys():
            pick -= alternative_tiles[tile]
            if pick <= 0.0:
                chosen_tile = tile
                break

        terrain_tilemap.set_cell(cell, source_id, chosen_tile)


func _load_patrol_points(patrol_tilemap: TileMapLayer, starting_tile: Vector2i) -> Array[Vector2i]:
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
    # print("Assign units to pods:")
    for tile in pods_tilemap.get_used_cells():
        var atlas_coords = pods_tilemap.get_cell_atlas_coords(tile)
        #if atlas_coords.y != 1: # only atlascords.y == 1 are valid unit assignations
        #    continue
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
    
func _load_train():
    # print("Loading horizontal train from game state")
    var train_data = GameState.get_player_train()
    horizontal_train = horizontal_train_manager.spawn_train(train_initial_tile, train_data)
    horizontal_train.set_speed(horizontal_train.max_speed)
    train_container.add_child(horizontal_train)
    print("Spawned horizontal train at tile: %s" % train_initial_tile)

# spawns units from tilemap placeholders.
# unit will carry the default weapon of its type
func _spawn_units(units_tilemap: TileMapLayer) -> void:
    for tile in units_tilemap.get_used_cells():
        var atlas_coords = units_tilemap.get_cell_atlas_coords(tile)
        var source_id = units_tilemap.get_cell_source_id(tile)
        var unit_type = UnitDatabase.get_unit_type_from_atlas_coords(atlas_coords)
        var owner_id = UnitDatabase.get_owner_id_from_atlas_coords(atlas_coords)
        var aux = UnitDatabase.get_unit_data(unit_type)

        var unit_info = {
            "unit_type": unit_type,
            "weapon_type": aux.default_weapon,
            "owner_id": owner_id
        }
        unit_manager.spawn_unit(tile, unit_info)

        # Remove the placeholder tile
        units_tilemap.erase_cell(tile)

func _spawn_pods(pods_tilemap: TileMapLayer, patrol_tilemap: TileMapLayer) -> void:
    for tile in pods_tilemap.get_used_cells():
        var atlas_coords = pods_tilemap.get_cell_atlas_coords(tile)
        if atlas_coords.y != 0: # only atlascords.y == 0 are valid pod locations
            continue

        # load the patrol route for this pod:
        var patrol_route = _load_patrol_points(patrol_tilemap, tile)

        var id = "p%s" % atlas_coords.x
        pod_manager.spawn_pod(id, tile, patrol_route)

        # Remove the placeholder tile
        #pods_tilemap.erase_cell(tile)

    
func _spawn_buildings(buildings_tilemap: TileMapLayer) -> void:
    for tile in buildings_tilemap.get_used_cells():
        var atlas_coords = buildings_tilemap.get_cell_atlas_coords(tile)
        var building_type = BuildingTypes.get_building_type_from_atlas_coords(atlas_coords)
        var owner_id = 0
        building_manager.spawn_building(tile, building_type, owner_id)

        # Remove the placeholder tile
        buildings_tilemap.erase_cell(tile)


func _spawn_walls(walls_container: Node2D) -> void:
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

func _spawn_roads(roads_tilemap: TileMapLayer) -> void:
    for tile in roads_tilemap.get_used_cells():
        road_service.spawn_road(tile)
#endregion

# -process, _process_intro, _process_outro
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

#_unhandled_input, _handle_wagon_click _handle_tile_click, _handle_key_press, _handle_global_input
#region input
# check global inputs, mouse clicks and key presses. Passes mouse clicks and key presses to the state machine
func _unhandled_input(event: InputEvent) -> void:
    if _handle_global_input(event):
        return

    if event is InputEventMouseButton and event.pressed:
        var mouse_pos = get_local_mouse_position()
        # print("Mouse pressed: %s" % mouse_pos)

        # Check if we clicked a wagon
        var clicked_wagon_id = horizontal_train_manager.check_wagon_click(mouse_pos)
        if clicked_wagon_id != -1:
            _handle_wagon_click(clicked_wagon_id)
            return

            
        var tile = grid_service.world_to_tile(mouse_pos)
        _handle_tile_click(tile, event.button_index)
            
    if event is InputEventKey and event.pressed and not event.echo:
        _handle_key_press(event)

func _handle_wagon_click(wagon_id: int) -> void:
    print("Wagon clicked: %s" % wagon_id)
    var wagon = horizontal_train_manager.player_train.wagons[wagon_id]
    state_machine.set_state("WagonSelectedState", {
        "wagon_id": wagon_id,
        "wagon": wagon,
    })


func _handle_tile_click(tile: Vector2i, button_index: int) -> void:
    # print("Tile clicked %s" % tile)
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
#endregion

# update_state_label, update_turn_label, update_mouse_label, update_camera_label, update_labels
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

# _unit_reached_destination _unit_changed_orientation
#region unit signal handling
func _unit_reached_destination(unit):
    state_machine.set_state("UnitSelectedState", {"selected_unit": unit})
    _update_enemy_visibility()

func _unit_changed_orientation(unit, new_orientation):
    exploration_service.on_unit_orientation_changed(unit, new_orientation)
    _update_enemy_visibility()

func _on_unit_died(_unit: Unit) -> void:
    if unit_manager.get_units_by_team("Enemy").is_empty():
        _on_combat_victory()
    elif unit_manager.get_units_by_team("Player").is_empty():
        _on_combat_defeat()

func _on_combat_victory() -> void:
    print("[CombatScene] VICTORY — all enemies defeated")
    state_machine.set_state("CombatEndState", {"result": "victory"})

func _on_combat_defeat() -> void:
    print("[CombatScene] DEFEAT — all player units lost")
    state_machine.set_state("CombatEndState", {"result": "defeat"})

func show_end_screen(result: String) -> void:
    var msg = "VICTORY!" if result == "victory" else "DEFEAT"
    state_label.text = msg
    state_label.add_theme_color_override("font_color",
        Color.GREEN if result == "victory" else Color.RED)
    if result == "victory":
        # Give the player a moment to see the result, then trigger the outro
        await get_tree().create_timer(2.0).timeout
        is_outro = true
#endregion


func select_next_unit():
    var next_unit = unit_manager.get_next_unit_by_team("Player")
    if next_unit:
        state_machine.set_state("UnitSelectedState", {"selected_unit": next_unit})


# called by bullet.gd when it crosses a wall edge between two tiles
func on_bullet_hit_wall_edge(tile_a: Vector2i, tile_b: Vector2i, damage: int) -> void:
    print("[CombatScene] Bullet hit wall edge between %s and %s, damage: %d" % [tile_a, tile_b, damage])
    # WallFull nodes are registered in tile_occupancy_service on their own tile.
    # WallEdge nodes are NOT in tile_occupancy_service, so we check both tiles
    # and apply damage to the first wall-like entity found.
    for tile in [tile_a, tile_b]:
        for entity in tile_occupancy_service.get_entities(tile):
            if entity is WallFull:
                wall_manager.apply_damage_to_wall(entity, damage)
                return
            if entity is WallEdge:
                wall_manager.apply_damage_to_wall_edge(entity, damage)
                return

# called by Projectile._on_hit() when is_explosive is true
func on_explosion(world_pos: Vector2, radius_tiles: int, damage: int) -> void:
    print("[CombatScene] Explosion at %s, radius: %d, damage: %d" % [world_pos, radius_tiles, damage])
    var center_tile = grid_service.world_to_tile(world_pos)
    for dx in range(-radius_tiles, radius_tiles + 1):
        for dy in range(-radius_tiles, radius_tiles + 1):
            var tile = center_tile + Vector2i(dx, dy)
            for entity in tile_occupancy_service.get_entities(tile):
                if entity is Unit:
                    unit_manager.apply_damage_to_unit(entity, damage)
                elif entity is WallFull:
                    wall_manager.apply_damage_to_wall(entity, damage)
                elif entity is WallEdge:
                    wall_manager.apply_damage_to_wall_edge(entity, damage)

# TODO: this called by bullet.gd. But bullet also emits bullet_hit signal
func on_bullet_hit(position: Vector2i, damage: int):
    #convert position to tile
    var tile_ = grid_service.world_to_tile(position)
    print("Combat scene on bullet hit ", position, "  ", tile_)
    var entities_ = tile_occupancy_service.get_entities(tile_)
    print("Entities found in tile: ", entities_)
    if entities_.size() > 0:
        if entities_[0] is Unit:
            unit_manager.apply_damage_to_unit(entities_[0], damage)
        else:
            wall_manager.apply_damage_to_wall(entities_[0], damage)

# called by combat_unit_aiming_state when entering/exit the state    
func set_cursor(cursor_name: String) -> void:
    if cursor_name == "aim":
        aim_cursor.visible = true
    elif cursor_name == "":
        aim_cursor.visible = false

# TODO: called by CombatScene._unit_reached_destination !! should be unit_changed_tile
#                  CombatScene._unit_changed_orientation
func _update_enemy_visibility():
    var visible_tiles = exploration_service.get_merged_visible_tiles()
    #print("CombatScene: N Visible tiles: %s" % visible_tiles.size())
    for enemy in unit_manager.get_units_by_team("Enemy"):
        if enemy.current_tile in visible_tiles:
            # print("Showing enemy %s" % enemy.id)
            enemy.show()
        else:
            # print("Hiding enemy %s" % enemy.id)
            enemy.hide()
