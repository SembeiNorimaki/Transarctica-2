extends Node
class_name UnitManager

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService
var navigation_graph_service: NavigationGraphService
var camera_controller: CameraController
var los_service: LOSService
var cover_service: CoverService
var weapon_service: WeaponService
var pathfinding_service: PathfindingService
var accuracy_service: AccuracyService
var defensiveness_overlay: DefensivenessOverlay
var fov_overlay: FOVOverlay
var paths_overlay: PathOverlay

var unit_paths := {} # Dict of units -> path
var units_to_tile := {} # Dict of units -> tile_position

var next_unit_id = {"Player": 0, "Enemy": 0}

var teams = ["Player", "Enemy"]
var units = {"Player": [], "Enemy": []}

var visible_tiles_by_unit = {}

# this are enemies currently seen by each unit (enemies inside vision)
var seen_enemies_by_unit = {} # {unit1: [enemy1, enemy2], "unit2": [enemy3, enemy4]}

# this are enemies that are NOT currently seen by the unit but where seen this turn.
# this is useful when a unit turns left and right to scan surroundings.
# the unit can then spot enemies that will no longer be seen when the unit looks forward again
# at the end of the turn this enemies should be forgotten, since otherwise the unit will know where they are even if they move
var remembered_enemies_by_unit = {}

var cycle_idx = {"Player": - 1, "Enemy": - 1}

var selected_unit = null

signal unit_spawned(unit)
signal unit_arrived_to_tile(unit, new_tile)
signal unit_reached_destination(unit)
signal unit_changed_orientation(unit, new_orientation)
signal unit_visibility_changed(unit, new_spotted: Array, lost_sight: Array)
signal unit_path_started(unit, path)
signal unit_died(unit)

#signal unit_action_finished(unit)


func _ready() -> void:
    pass

func _inject_dependencies() -> void:
    pass

func _wire_signals() -> void:
    pass

#region unit spawning
#func spawn_unit(tile_pos: Vector2i, unit_type_: String, owner_id: String) -> Unit:
func spawn_unit(tile_pos: Vector2i, unit_info: Dictionary) -> Unit:
    # unit_info must have:
    #   - unit_type: String = "liquidator"
    #   - weapon_type: String = "AK47"
    #   - owner_id: String = "Player"
    # }
    print("UnitManager: Spawning unit of type %s" % unit_info.unit_type)

    # TODO: Some units already have an id!
    var id = "u%s%s" % [unit_info.owner_id[0], next_unit_id[unit_info.owner_id]] # Player unit with id=3 -> uP3
    next_unit_id[unit_info.owner_id] += 1
    
    var unit = UnitDatabase.get_scene(unit_info.unit_type).instantiate()
    
    # Dependency injection
    unit.grid_service = grid_service
    unit.unit_manager = self
    unit.navigation_graph_service = navigation_graph_service

    unit.call_deferred("set_soldier_type", unit_info.unit_type)
    unit.call_deferred("set_weapon_type", unit_info.weapon_type)
    unit.call_deferred("initialize", id, tile_pos, unit_info.owner_id)
    
    units[unit_info.owner_id].append(unit)

    
    # Add to scene tree
    get_node("../../Containers/Units").add_child(unit)

    # Register in occupancy
    var footprint = UnitDatabase.get_footprint(unit_info.unit_type)
    print("footprint: ", footprint)
    for offset in FootprintDatabase.get_footprint(footprint):
        tile_occupancy_service.register(tile_pos + offset, unit)

    # Register in units_to_tile
    units_to_tile[unit] = tile_pos

    # Forward the unit's per-tile arrival to unit_manager so occupancy + vision stay in sync
    unit.unit_arrived_to_tile.connect(_on_unit_arrived_to_tile)

    emit_signal("unit_spawned", unit)
    return unit

#endregion


#region Tile Tracking


func get_unit_tile(unit: Unit) -> Vector2i:
    return units_to_tile.get(unit, Vector2i(-1, -1))

#endregion

#region Public API
func select_unit(unit, center_camera = true):
    selected_unit = unit
    if center_camera:
        camera_controller.center_at_tile(unit.current_tile)

func unselect_unit():
    selected_unit = null

func get_next_unit_by_team(team: String) -> Unit:
    if units[team].is_empty():
        return null
    cycle_idx[team] = (cycle_idx[team] + 1) % units[team].size()
    return units[team][cycle_idx[team]]

func get_units_by_team(team: String) -> Array:
    return units.get(team, [])

func get_all_units() -> Array:
    var all_units = []
    all_units.append_array(get_units_by_team("Player"))
    all_units.append_array(get_units_by_team("Enemy"))
    return all_units

func apply_damage_to_unit(unit: Unit, amount: int):
    unit.apply_damage(amount)

func remove_unit(unit: Unit) -> void:
    var team = unit.team_id
    units[team].erase(unit)
    # Unregister from occupancy so the tile is freed for other units
    tile_occupancy_service.unregister(units_to_tile.get(unit, unit.current_tile), unit)
    units_to_tile.erase(unit)
    # Also clean up vision tracking
    visible_tiles_by_unit.erase(unit)
    # Remove the dead unit from every observer's seen-enemies list
    for observer in seen_enemies_by_unit:
        seen_enemies_by_unit[observer].erase(unit)
    seen_enemies_by_unit.erase(unit)
    emit_signal("unit_died", unit)


func can_unit_see_enemy(unit: Unit, enemy: Unit) -> bool:
    if seen_enemies_by_unit.get(enemy, null) == null:
        return false
    return true
    

#endregion


#region shoot
func request_shoot(shooter: Unit, target_tile: Vector2i) -> bool:
    # Validate AP
    if shooter.get_ap() < shooter.weapon.ap_cost:
        # print("Error, not enough AP to shoot")
        return false
    
    # Validate LOS
    #if not los_service.has_los(shooter.current_tile, target_tile):
        # print("Error, no LOS to target tile")
        #return false
    
    # Validate range
    var dist = shooter.current_tile.distance_to(target_tile)
    if dist > shooter.weapon.max_range:
        # print("Error, target tile out of range")
        return false
    
    execute_shoot(shooter, target_tile)
    return true

func execute_shoot(shooter: Unit, target_tile: Vector2i) -> void:
    # Deduct AP
    shooter.ap_component.use_ap(shooter.weapon.ap_cost)

    # Pass through AimState first so the weapon sprite is raised,
    # then AimState will auto-chain into AttackState immediately.
    shooter.action_sm.set_state("AimState", {
        "unit": shooter,
        "target_tile": target_tile,
        "weapon_service": weapon_service,
        "auto_fire": true
    })


func on_projectile_hit(shooter: Unit, target: Unit) -> void:
    apply_damage_to_unit(target, shooter.weapon.damage)

func has_unit_good_shoot(shooter: Unit, enemy: Unit) -> bool:
    return true

func get_hit_chance_for(shooter: Unit, target: Unit) -> float:
    return 1.0

#endregion

#region cover
# Returns true if the unit has ANY cover in ANY direction
func is_unit_in_cover(unit) -> bool:
    return cover_service.get_cover_value(unit.current_tile) > 0.0

# Returns true if the unit has cover AGAINST a specific enemy
func is_unit_in_cover_against_enemy(unit, enemy) -> bool:
    var cover_val = cover_service.get_cover_against(unit.current_tile, enemy.current_tile)
    return cover_val > 0.0

func is_unit_in_cover_against_all_enemies(unit, enemies: Array) -> bool:
    for enemy in enemies:
        # Skip enemies the unit cannot see (fair AI, no omniscience)
        if not unit.unit_manager.can_unit_see_enemy(unit, enemy):
            continue

        if not is_unit_in_cover_against_enemy(unit, enemy):
            return false

    return true

func get_cover_of_enemy_against(unit, enemy) -> float:
    return cover_service.get_cover_against(enemy.current_tile, unit.current_tile)
    

# # Finds the best cover tile relative to a specific enemy
# func find_best_cover(unit, enemy) -> Vector2i:
#     print("Finding best cover for unit in %s against enemy in %s" % [unit.current_tile, enemy.current_tile])
#     var best_tile = unit.current_tile
#     var best_cover := cover_service.get_cover_against(unit.current_tile, enemy.current_tile)

#     # TODO: get_reachable_tiles not yet implemented
#     for tile in navigation_graph_service.get_reachable_tiles(unit, 4.0):
#         var cover = cover_service.get_cover_against(tile, enemy.current_tile)
#         print("Tile %s: cover value %s" % [tile, cover])
#         if cover > best_cover:
#             best_cover = cover
#             best_tile = tile
#     return best_tile


# From all reachable tiles, find the one with highest score against all enemies
func find_safest_tile(unit, enemies: Array) -> Vector2i:
    var best_tile = unit.current_tile
    var best_score = evaluate_tile_defensiveness(unit.current_tile, enemies)

    for tile in navigation_graph_service.get_reachable_tiles(unit, 10.0):
        # Skip tiles already occupied by another unit
        if tile_occupancy_service.is_occupied(tile):
            continue
        var score := evaluate_tile_defensiveness(tile, enemies)
        if score > 0.0:
            defensiveness_overlay.danger_map[tile] = score
        
        if score > best_score:
            best_score = score
            best_tile = tile

    defensiveness_overlay.update()
    # print("def map: %s" % defensiveness_overlay.danger_map)
    return best_tile

# evaluates how good is a tile agains all known enemies
func evaluate_tile_defensiveness(tile: Vector2i, enemies: Array) -> float:
    var score := 0.0

    for enemy in enemies:
        var cover := cover_service.get_cover_against(tile, enemy.current_tile)
        if cover == 0.0:
            return cover
            
        var has_los: bool = los_service.has_los(tile, enemy.current_tile)
        #var is_flanked := cover == 0 and has_los

        # Cover contribution
        score += cover * 10.0

        # LOS from to enemy is good
        if has_los:
            score += 5.0

        # Flanked is VERY bad
        #if is_flanked:
        #    score -= 30.0

    return score


#endregion

#region enemy selection
func choose_best_target(unit: Unit, enemies: Array) -> Unit:
    var best_enemy = null
    var best_score := -INF

    for enemy in enemies:
        if not los_service.has_los(unit.current_tile, enemy.current_tile):
            continue

        var hit = accuracy_service.compute_hit_chance(unit, unit.weapon, unit.current_tile, enemy.current_tile)
        var flank_bonus = 0.0
        if cover_service.get_cover_against(enemy.current_tile, unit.current_tile) == 0.0:
            flank_bonus = 20.0

        var score = hit + flank_bonus

        if score > best_score:
            best_score = score
            best_enemy = enemy

    return best_enemy
#endregion


#region Movement orchestration

func calculate_path_for_unit(unit: Unit, target_tile: Vector2i) -> Array[Vector2i]:
    var path_and_cost = pathfinding_service.find_path(unit.current_tile, target_tile)
    if path_and_cost.is_empty():
        return []
    var path = path_and_cost[0]
    return path

    
func start_unit_movement(unit: Unit, path: Array[Vector2i]) -> void:
    #print("Received path %s for unit %s" % [path, unit.id])
    path.pop_front() # remove first point since it's the current tile
    unit_path_started.emit(unit, path)
    unit_paths[unit] = path
    _give_next_tile(unit)
    unit.set_state("MoveState", {"unit": unit})

func _give_next_tile(unit: Unit) -> void:
    var path = unit_paths[unit]
    if path.is_empty():
        _on_unit_reached_destination(unit)
    else:
        var next_tile = path.pop_front()
        unit.move_to_tile(next_tile)

func _on_unit_reached_destination(unit):
    # print("Unit reached destination")
    # set the unit state to idle
    unit.set_state("IdleState", {"unit": unit})
    unit.play_animation("IdleState", unit.orientation)
    #unit.unit_ai.on_unit_reached_destination(unit)
    emit_signal("unit_reached_destination", unit)

func update_vision(unit: Unit) -> void:
    # compute vision
    var cone_tiles = grid_service.get_tiles_in_vision_cone(unit.current_tile, unit.orientation, unit.view_angle, unit.view_range)
    var visible_tiles = los_service.filter_visible_tiles(unit.current_tile, cone_tiles)
    visible_tiles_by_unit[unit] = visible_tiles
    
    fov_overlay._tiles_to_draw_blue = visible_tiles
    fov_overlay.redraw()

func recalculate_all_units_vision():
    for unit in get_units_by_team("Player"):
        update_vision(unit)
    for unit in get_units_by_team("Enemy"):
        update_vision(unit)
        
func recalculate_all_units_seen_enemies():
    for unit in get_units_by_team("Player"):
        _update_seen_enemies(unit, get_visible_tiles_for(unit))
    for unit in get_units_by_team("Enemy"):
        _update_seen_enemies(unit, get_visible_tiles_for(unit))

func _on_unit_arrived_to_tile(unit, new_tile: Vector2i):
    # update occupancy
    tile_occupancy_service.unregister(unit.current_tile, unit)
    tile_occupancy_service.register(new_tile, unit)
    
    # update ap
    unit.ap_component.use_ap(1)
    unit.update_ap_label()
    
    # update tile
    unit.current_tile = new_tile
    units_to_tile[unit] = new_tile
    unit.update_tile_label()
    
    update_vision(unit)

    # compute seen enemies
    _update_seen_enemies(unit, visible_tiles_by_unit[unit])
    
    # continue movement
    _give_next_tile(unit)
    
    # notify CombatScene
    unit_arrived_to_tile.emit(unit, new_tile)
    
    
func get_visible_tiles_for(unit):
    return visible_tiles_by_unit[unit]

func get_seen_enemies_for(unit):
    # compute enemies seen
    _update_seen_enemies(unit, visible_tiles_by_unit[unit])
    return seen_enemies_by_unit[unit]
    

func get_primary_target_for(unit):
    var enemies_seen = get_seen_enemies_for(unit)
    # print("Number of enemies seen: %s" % enemies_seen.size())
    return enemies_seen[0] if enemies_seen else null


func _update_seen_enemies(unit, visible_tiles: Array[Vector2i]):
    #var previous = seen_enemies_by_unit.get(unit, [])
    var current = []

    # 1) Find all enemy units inside visible tiles
    for tile in visible_tiles:
        var occupants = tile_occupancy_service.get_units(tile)
        if occupants.size() > 0 and occupants[0].team_id != unit.team_id:
            current.append(occupants[0])
        
        # TODO: not valid gdscript syntax
        var newly_spotted = [] # current.filter(e not in previous)
        var lost_sight = [] # previous.filter(e not in current)

        seen_enemies_by_unit[unit] = current

        unit_visibility_changed.emit(unit, newly_spotted, lost_sight)

func on_unit_orientation_changed(unit: Unit, new_orientation: String) -> void:
    update_vision(unit)
    
    # compute seen enemies
    _update_seen_enemies(unit, visible_tiles_by_unit[unit])

    # notify CombatScene
    unit_changed_orientation.emit(unit, new_orientation)


#endregion


#region WASD unit movement and aiming
# This functions are used to move the selected unit with WASD and aim with the right mouse button
func on_move_vector_changed(vec: Vector2i):
    # print("UM on move vector changed: %s" % vec)
    if vec == Vector2i.ZERO:
        return
    var selected_unit = units["Player"][next_unit_id["Player"] - 1]

    start_unit_movement(selected_unit, [selected_unit.current_tile, selected_unit.current_tile + vec])

func on_aim_pressed():
    # print("UM on aim pressed")
    pass
func on_aim_released():
    # print("UM on aim released")
    pass
#endregion
