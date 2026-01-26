extends Node
class_name UnitManager

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService

var unit_paths := {} # Dict of units -> path
var units_to_tile := {} # Dict of units -> tile_position

var next_unit_id = {"Player": 0, "Enemy": 0}

var teams = ["Player", "Enemy"]
var units = {"Player": [], "Enemy": []}

var cycle_idx = {"Player": - 1, "Enemy": - 1}

signal unit_spawned(unit)
signal unit_tile_changed(unit, old_tile, new_tile)
signal unit_reached_destination(unit)
signal unit_changed_orientation(unit, new_orientation)


func _ready() -> void:
	pass

#region unit spawning
func spawn_unit(tile_pos: Vector2i, unit_type_: String) -> void:
	var unit_info = UnitTypes.TYPES[unit_type_]
	var team = unit_info.team
	var footprint = unit_info.footprint

	print("Spawning a %s" % unit_type_)
	var id = "u%s%s" % [team[0], next_unit_id[team]] # Player unit with id=3 -> uP3
	next_unit_id[team] += 1
	
	var unit = unit_info.scene.instantiate()
	
	# Dependency injection
	unit.grid_service = grid_service
	unit.unit_manager = self

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
func _on_unit_tile_changed(unit: Unit, old_tile: Vector2i, new_tile: Vector2i) -> void:
	tile_occupancy_service.unregister(old_tile, unit)
	tile_occupancy_service.register(new_tile, unit)
	units_to_tile[unit] = new_tile
	emit_signal("unit_tile_changed", unit, old_tile, new_tile)

# called by the unit itself
func on_unit_orientation_changed(unit: Unit, new_orientation: String) -> void:
	emit_signal("unit_changed_orientation", unit, new_orientation)

func get_unit_tile(unit: Unit) -> Vector2i:
	return units_to_tile.get(unit, Vector2i(-1, -1))

#endregion

#region Public API
func get_next_unit_by_team(team: String) -> Unit:
	if units[team].is_empty():
		return null
	cycle_idx[team] = (cycle_idx[team] + 1) % units[team].size()
	return units[team][cycle_idx[team]]

func get_units_by_team(team: String) -> Array[Unit]:
	return units.get(team, [])

func get_all_units() -> Array[Unit]:
	var all_units = []
	for team in units:
		all_units.append_array(units[team])
	return all_units


#endregion

#region Movement orchestration
func start_unit_movement(unit: Unit, path: Array[Vector2i]) -> void:
	#print("Received path %s for unit %s" % [path, unit.id])
	path.pop_front() # remove first point since it's the current tile
	unit_paths[unit] = path
	_give_next_tile(unit)

func _give_next_tile(unit: Unit) -> void:
	var path = unit_paths[unit]
	if path.is_empty():
		_on_unit_reached_destination(unit)
	else:
		var next_tile = path.pop_front()
		unit.move_to_tile(next_tile)

func _on_unit_reached_destination(unit):
	# set the unit state to idle
	unit.set_state("IdleState", {"unit": unit})
	emit_signal("unit_reached_destination", unit)
	
func on_unit_reached_tile(unit: Unit, tile: Vector2i) -> void:
	_on_unit_tile_changed(unit, unit.current_tile, tile)
	unit.current_tile = tile
	_give_next_tile(unit)
#endregion
