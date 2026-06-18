extends Node
class_name UnitManager

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService
var navigation_graph_service: NavigationGraphService
var camera_controller: CameraController
var los_service: LOSService

var unit_paths := {} # Dict of units -> path
var units_to_tile := {} # Dict of units -> tile_position

var next_unit_id = {"Player": 0, "Enemy": 0}

var teams = ["Player", "Enemy"]
var units = {"Player": [], "Enemy": []}

var visible_tiles_by_unit = {}
var seen_enemies_by_unit = {}

var cycle_idx = {"Player": - 1, "Enemy": - 1}

var selected_unit = null

signal unit_spawned(unit)
signal unit_arrived_to_tile(unit, new_tile)
signal unit_reached_destination(unit)
signal unit_changed_orientation(unit, new_orientation)
signal unit_visibility_changed(unit, new_spotted: Array, lost_sight: Array)

#signal unit_action_finished(unit)

func _ready() -> void:
	pass

func _inject_dependencies() -> void:
	pass

func _wire_signals() -> void:
	pass

#region unit spawning
func spawn_unit(tile_pos: Vector2i, unit_type_: String, owner_id: String) -> void:
	var unit_info = UnitTypes.TYPES["unit_xcom"]
	var team = owner_id
	var footprint = unit_info.footprint

	print("Spawning a %s belonging to %s to tile %s" % [unit_type_, owner_id, tile_pos])
	var id = "u%s%s" % [team[0], next_unit_id[team]] # Player unit with id=3 -> uP3
	next_unit_id[team] += 1
	
	var unit = unit_info.scene.instantiate()
	
	unit.call_deferred("set_soldier_type", unit_type_)
	unit.call_deferred("set_weapon_type", "TacticalSniperRifle")
	#unit.call_deferred("set_weapon_type", "AK47")

	# Dependency injection
	unit.grid_service = grid_service
	unit.unit_manager = self
	unit.navigation_graph_service = navigation_graph_service

	unit.call_deferred("initialize", id, team)
	unit.position = grid_service.tile_to_world(tile_pos)
	unit.current_tile = tile_pos

	units[team].append(unit)

	
	# Add to scene tree
	get_node("../../Containers/Units").add_child(unit)

	# Register in occupancy
	for offset in UnitTypes.FOOTPRINTS[footprint]:
		tile_occupancy_service.register(tile_pos + offset, unit)

	# Register in units_to_tile
	units_to_tile[unit] = tile_pos

	# Connect the tile_change signal
	#unit.connect("tile_changed", self._on_unit_tile_changed)
	#	unit.connect("orientation_changed", self._on_unit_orientation_changed)

	emit_signal("unit_spawned", unit)

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

#endregion

#region Movement orchestration
func start_unit_movement(unit: Unit, path: Array[Vector2i]) -> void:
	#print("Received path %s for unit %s" % [path, unit.id])
	path.pop_front() # remove first point since it's the current tile
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
	print("Unit reached destination")
	# set the unit state to idle
	unit.set_state("IdleState", {"unit": unit})
	unit.play_animation("IdleState", unit.orientation)
	unit.unit_ai.on_unit_reached_destination(unit)
	emit_signal("unit_reached_destination", unit)


func update_vision(unit: Unit) -> void:
	# compute vision
	var cone_tiles = grid_service.get_tiles_in_vision_cone(unit.current_tile, unit.orientation, unit.view_angle, unit.view_range)
	var visible_tiles = los_service.filter_visible_tiles(unit.current_tile, cone_tiles)
	visible_tiles_by_unit[unit] = visible_tiles

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
	unit_arrived_to_tile.emit()
	
	
func get_visible_tiles_for(unit):
	return visible_tiles_by_unit[unit]

func get_seen_enemies_for(unit):
	return seen_enemies_by_unit[unit]
	

func get_primary_target_for(unit):
	var enemies_seen = get_seen_enemies_for(unit)
	print("Number of enemies seen: %s" % enemies_seen.size())
	return enemies_seen[0] if enemies_seen else null


func _update_seen_enemies(unit, visible_tiles: Array[Vector2i]):
	#var previous = seen_enemies_by_unit.get(unit, [])
	var current = []

	# 1) Find all enemy units inside visible tiles
	for tile in visible_tiles:
		var occupants = tile_occupancy_service.get_units(tile)
		if occupants.size() > 0 and occupants[0].team_id == "Enemy":
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
	print("UM on move vector changed: %s" % vec)
	if vec == Vector2i.ZERO:
		return
	var selected_unit = units["Player"][next_unit_id["Player"] - 1]

	start_unit_movement(selected_unit, [selected_unit.current_tile, selected_unit.current_tile + vec])

func on_aim_pressed():
	print("UM on aim pressed")

func on_aim_released():
	print("UM on aim released")

#endregion
