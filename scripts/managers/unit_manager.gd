extends Node
class_name UnitManager

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService

var unit_paths := {} # Dict of units -> path
var units_to_tile := {} # Dict of units -> tile_position

var next_unit_id: int = 0
var units

signal unit_spawned(unit)
signal unit_tile_changed(unit, old_tile, new_tile)


func _ready() -> void:
	pass

func spawn_unit(tile_pos, unit_type, owner_id) -> void:
	print("Spawning a %s" % unit_type)

	var id = "u" + str(next_unit_id)
	next_unit_id += 1

	var unit_type_ = UnitTypes.TYPES[unit_type]
	var unit = unit_type_.scene.instantiate()
	
	unit.grid_service = grid_service
	unit.unit_manager = self

	unit.call_deferred("initialize", id)
	
	# convert tile -> world
	var world_pos = grid_service.tile_to_world(tile_pos)
	unit.position = world_pos

	# Initialize unit data
	unit.current_tile = tile_pos

	# Add to scene tree
	get_node("../../Containers/Units").add_child(unit)

	# Register in occupancy
	tile_occupancy_service.register(tile_pos, unit)

	# Register in units_to_tile
	units_to_tile[unit] = tile_pos

	# Connect the tile_change signal
	unit.connect("unit_tile_changed", self._on_unit_tile_changed)

	emit_signal("unit_spawned", unit)

func _on_unit_tile_changed(unit: Unit, old_tile: Vector2i, new_tile: Vector2i) -> void:
	tile_occupancy_service.unregister(old_tile, unit)
	tile_occupancy_service.register(new_tile, unit)
	units_to_tile[unit] = new_tile
	#emit_signal("unit_tile_changed", unit, old_tile, new_tile)


func get_unit_tile(unit: Unit) -> Vector2i:
	return units_to_tile.get(unit, Vector2i(-1, -1))

func register_unit(unit: Unit, tile_pos: Vector2i) -> void:
	pass
	
func unregister_unit(unit: Unit) -> void:
	pass

func start_unit_movement(unit: Unit, path: Array[Vector2i]) -> void:
	print("Received path %s for unit %s" % [path, unit.id])
	unit_paths[unit] = path
	_give_next_tile(unit)

func _give_next_tile(unit: Unit) -> void:
	var path = unit_paths[unit]
	if path.is_empty():
		unit.on_movement_finished()
		unit_paths.erase(unit)
		return
	var next_tile = path.pop_front()
	unit.move_to_tile(next_tile)

func on_unit_reached_tile(unit: Unit) -> void:
	_give_next_tile(unit)

func _process(delta: float) -> void:
	pass
