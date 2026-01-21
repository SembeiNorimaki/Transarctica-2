extends Node
class_name BuildingManager

# Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService

var buildings_to_tile := {} # Dict of buildings -> tile_position

const BUILDING_SCENES = {
	"barracks": preload("res://scenes/entities/buildings/barracks.tscn"),
	"power_plant": preload("res://scenes/entities/buildings/power_plant.tscn")
}

signal building_spawned(building)

func _ready() -> void:
	pass

func spawn_building(tile_pos, building_type, owner_id) -> void:
	#print("Spawning a %s at location %s" % [building_type, tile_pos])
	var building_type_ = BuildingTypes.TYPES[building_type]
	var building = building_type_.scene.instantiate()
	var building_footprint_ = building_type_.footprint
	var building_tiles_ = BuildingTypes.FOOTPRINTS[building_footprint_]

	
	# convert tile -> world
	var world_pos = grid_service.tile_to_world(tile_pos)
	building.position = world_pos

	# Initialize unit data
	building.current_tile = tile_pos

	# Add to scene tree
	get_node("../../Containers/Buildings").add_child(building)

	# Register in occupancy
	for tile_offset in building_tiles_:
		tile_occupancy_service.register(tile_pos + tile_offset, building)

	# Register in buildings_to_tile
	buildings_to_tile[building] = tile_pos

	# Connect the tile_change signal
	#building.connect("building_tile_changed", self._on_building_tile_changed)

	emit_signal("building_spawned", building)

func register_building(building: Building, tile_pos: Vector2i) -> void:
	pass

func unregister_building(building: Building) -> void:
	pass
