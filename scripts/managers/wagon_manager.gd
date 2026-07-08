extends Node
class_name WagonManager

# Injected by CombatScene
var horizontal_train_manager: HorizontalTrainManager = null
var grid_service: GridService = null
var tile_occupancy_service: TileOccupancyService = null
var unit_manager: UnitManager = null

# Emitted after a unit is successfully unloaded so the HUD can refresh
signal unit_unloaded(wagon_id: int)

# Candidate tiles above the wagon (isometric "north" offsets), checked in order
const SPAWN_OFFSETS: Array[Vector2i] = [
	Vector2i(-2, -2),
	Vector2i(-2, -1),
	Vector2i(-1, -2),
]

# Called from WagonHUD when the player clicks a unit portrait.
# wagon_id: index of the wagon in the player train
# unit_id:  GameState soldier id (e.g. "s0")
func request_unit_unloading(wagon_id: int, unit_id: String) -> void:
	print("[WagonManager] request_unit_unloading wagon_id=%s unit_id=%s" % [wagon_id, unit_id])

	# Get the live wagon node and convert its world position to a grid tile
	var wagon = horizontal_train_manager.player_train.wagons[wagon_id]
	var wagon_tile := grid_service.world_to_tile(wagon.global_position)

	# Find the first unoccupied candidate tile
	var deploy_tile := _find_free_tile(wagon_tile)
	if deploy_tile == Vector2i(-1, -1):
		push_warning("[WagonManager] No free deploy tile near wagon %s" % wagon_id)
		return

	# Resolve unit type from GameState
	var unit_data: Dictionary = GameState.get_unit(unit_id)
	var unit_type: String = unit_data.get("type", "unit_xcom")

	# Spawn the unit on the grid
	var spawned_unit := unit_manager.spawn_unit(deploy_tile, unit_type, "Player")
	spawned_unit.call_deferred("set_orientation", "NW")

	# Remove the soldier from the barracks wagon in GameState
	GameState.remove_unit_from_barracks(unit_id)

	# Notify listeners (e.g. WagonHUD) to refresh
	unit_unloaded.emit(wagon_id)


func _find_free_tile(wagon_tile: Vector2i) -> Vector2i:
	for offset in SPAWN_OFFSETS:
		var candidate := wagon_tile + offset
		if grid_service.is_inside_map(candidate) and tile_occupancy_service.get_entities(candidate).is_empty():
			return candidate
	return Vector2i(-1, -1)
