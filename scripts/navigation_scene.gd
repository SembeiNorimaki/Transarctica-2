extends Node2D

# Managers
@onready var train_manager = $Managers/TrainManager
@onready var cities_manager = $Managers/CitiesManager

# Overlays
@onready var rails_overlay = $Overlays/RailsOverlay
@onready var cities_overlay = $Overlays/CitiesOverlay

# Services
@onready var grid_service = $Services/GridService
@onready var rail_service = $Services/RailService

# Map 
@onready var map_root = $MapRoot
@onready var exploration_layer = $MapRoot/ExplorationLayer

#Entities
@onready var player_train = $Containers/Trains/PlayerTrain

const ATLAS_TO_RAILNAME = {
	Vector2i(0, 0): "WE",
	Vector2i(1, 0): "NS",
	Vector2i(2, 0): "NW",
	Vector2i(3, 0): "NSW",
	
	Vector2i(0, 1): "SE",
	Vector2i(1, 1): "NE",
	Vector2i(2, 1): "SW",
	Vector2i(3, 1): "NSE",

	Vector2i(0, 2): "NSWE",
	Vector2i(1, 2): "",
	Vector2i(2, 2): "",
	Vector2i(3, 2): "NEW",

	Vector2i(0, 3): "",
	Vector2i(1, 3): "",
	Vector2i(2, 3): "",
	Vector2i(3, 3): "NES",

	Vector2i(0, 4): "NWSE",
	Vector2i(1, 4): "NESW",
	Vector2i(2, 4): "",
	Vector2i(3, 4): "SEW",

	Vector2i(0, 5): "NWS",
	Vector2i(1, 5): "NWE",
	Vector2i(2, 5): "SWN",
	Vector2i(3, 5): "SEN",
	
	Vector2i(0, 6): "SWE",
	Vector2i(1, 6): "WEN",
	Vector2i(2, 6): "WES",
	Vector2i(3, 6): "NX",

	Vector2i(0, 7): "WX",
	Vector2i(1, 7): "EX",
	Vector2i(2, 7): "SX",
	Vector2i(3, 7): "",

}

func _ready() -> void:
	grid_service.set_tile_size(Vector2i(128, 64))
	_inject_services()
	_wire_signals()
	_load_map("world_1")

func _inject_services():
	# Managers
	train_manager.grid_service = grid_service
	train_manager.rail_service = rail_service
	train_manager.cities_manager = cities_manager
	
	# Overlays
	rails_overlay.grid_service = grid_service
	rails_overlay.rail_service = rail_service
	cities_overlay.grid_service = grid_service
	cities_overlay.cities_manager = cities_manager

	# Services
	#player_train.grid_service = grid_service
	rail_service.rails_tilemap = $MapRoot/World1/Rails

func _wire_signals():
	#player_train.tile_changed.connect(_on_player_train_tile_changed)
	pass

func _load_map(map_name: String) -> void:
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
	grid_service.map_size = new_map.get_node("Terrain").get_used_rect().size
	
	_spawn_cities_from_map(new_map.get_node("Cities"))
	_build_rails_from_map(new_map.get_node("Rails"))
	_spawn_trains_from_map(new_map.get_node("Trains"))

func _spawn_cities_from_map(cities_tilemap: TileMapLayer) -> void:
	for tile in cities_tilemap.get_used_cells():
		cities_manager.spawn_city(tile)

func _spawn_trains_from_map(trains_tilemap: TileMapLayer) -> void:
	for tile in trains_tilemap.get_used_cells():
		var atlas_coords = trains_tilemap.get_cell_atlas_coords(tile)
		var source_id = trains_tilemap.get_cell_source_id(tile)
		var orientation = "E"
		var team = "Player"
		train_manager.spawn_train(tile, orientation, team)

		# Remove the placeholder tile
		trains_tilemap.erase_cell(tile)

func _build_rails_from_map(rails_tilemap: TileMapLayer) -> void:
	for tile in rails_tilemap.get_used_cells():
		var atlas_coords = rails_tilemap.get_cell_atlas_coords(tile)
		var source_id = rails_tilemap.get_cell_source_id(tile)
		var rail_name = ATLAS_TO_RAILNAME[atlas_coords]
		rail_service.spawn_rail(tile, rail_name)
	
	#rails_overlay.update()


func _on_player_train_tile_changed(from_tile: Vector2i, to_tile: Vector2i) -> void:
	print("Train changed tile")
	pass
	#rail_service.build_rail(to_tile)
