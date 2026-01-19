extends Node
class_name UnitManager

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService

var unit_paths := {} # Dict of units -> path
var units_to_tile := {} # Dict of units -> tile_position

var next_unit_id: int = 0
var units = []
var cycle_idx = -1

signal unit_spawned(unit)
signal unit_tile_changed(unit, old_tile, new_tile)
signal unit_reached_destination(unit)


func _ready() -> void:
	pass

#region unit spawning
func spawn_unit(tile_pos, unit_type, owner_id: String) -> void:
	print("Spawning a %s" % unit_type)

	var id = "u" + str(next_unit_id)
	
	
	var unit_type_ = UnitTypes.TYPES[unit_type]
	var unit = unit_type_.scene.instantiate()
	
	unit.grid_service = grid_service
	unit.unit_manager = self

	unit.call_deferred("initialize", id, owner_id)
	
	# convert tile -> world
	var world_pos = grid_service.tile_to_world(tile_pos)
	unit.position = world_pos

	# Initialize unit data
	unit.current_tile = tile_pos

	units.append(unit)
	next_unit_id += 1

	# Add to scene tree
	get_node("../../Containers/Units").add_child(unit)

	# Register in occupancy
	tile_occupancy_service.register(tile_pos, unit)

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
	print("AAA unit orientation changed")
	emit_signal("unit_changed_orientation", unit, new_orientation)

func get_unit_tile(unit: Unit) -> Vector2i:
	return units_to_tile.get(unit, Vector2i(-1, -1))

#endregion

func get_next_unit() -> Unit:
	if units.is_empty():
		return null
	cycle_idx = (cycle_idx + 1) % units.size()
	return units[cycle_idx]


#region Movement orchestration
func start_unit_movement(unit: Unit, path: Array[Vector2i]) -> void:
	print("Received path %s for unit %s" % [path, unit.id])
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
