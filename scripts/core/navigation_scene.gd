extends Node2D

# ─────────────────────────────────────────────
#  Methods:
#    _ready() -> void
#    _inject_services()
#    _wire_signals()
#
#    _load_map(map_name: String) -> void
#    _spawn_cities_from_map(cities_ids_tilemap: TileMapLayer) -> void
#    _spawn_trains_from_map(trains_tilemap: TileMapLayer) -> void
#    _build_rails_from_map(rails_tilemap: TileMapLayer) -> void
#    _build_bridges_from_map(bridges_tilemap: TileMapLayer) -> void
#    _spawn_wagons()
#
#    _unhandled_input(event: InputEvent) -> void
#    _handle_gear_toggle()
#    _handle_reverse_train()
#
#    _on_train_reached_city(city_name: String)
#
#    recenter_player_train()
#    reverse_player_train_direction()
#
#  Signals:
#    TrainManager.train_reached_city -> _on_train_reached_city
# ─────────────────────────────────────────────


# Managers
@onready var train_manager: NavigationTrainManager = $Managers/TrainManager
@onready var cities_manager: CitiesManager = $Managers/CitiesManager

# Overlays
@onready var rails_overlay: RailsOverlay = $Overlays/RailsOverlay
@onready var cities_overlay: CitiesOverlay = $Overlays/CitiesOverlay

# Services
@onready var grid_service: GridService = $Services/GridService
#@onready var tile_occupancy_service: TileOccupancyService = $Services/TileOccupancyService
@onready var rail_service: RailService = $Services/RailService

#Controllers
@onready var camera_controller: CameraController = $Controllers/CameraController

# Map 
@onready var map_root: Node2D = $MapRoot
@onready var exploration_layer: TileMapLayer = $MapRoot/ExplorationLayer

#Entities
#@onready var player_train: PlayerTrain = $Containers/Trains/PlayerTrain

# Containers
@onready var trains_container: Node2D = $Containers/Trains
@onready var wagon_container: Node2D = $Containers/Wagons
@onready var city_labels_container: Node2D = $Containers/CityLabels

const WAGON_SCENE: PackedScene = preload("res://scenes/entities/trains/navigation_wagon.tscn")

# Travelling.mp3 is the ambient travel music for the navigation/overworld screen.
const MUSIC_TRAVEL: AudioStream = preload("res://assets/audio/Travelling.mp3")
	
#region Lifecycle & Setup
func _ready() -> void:
	_inject_services()
	call_deferred("_wire_signals")
	_load_map("world_1")

	camera_controller.center_at_tile(Vector2i(15, 5))
	camera_controller.set_zoom(1.0)

	# Start the overworld travel music with a 2-second fade-in.
	AudioService.play_music(MUSIC_TRAVEL, 2.0)
	
func _inject_services() -> void:
	# Managers
	train_manager.grid_service = grid_service
	train_manager.rail_service = rail_service
	train_manager.cities_manager = cities_manager
	train_manager.exploration_layer = exploration_layer
	train_manager.camera_controller = camera_controller
	
	cities_manager.rail_service = rail_service
	cities_manager.city_labels_container = city_labels_container
	cities_manager.grid_service = grid_service

	# Overlays
	rails_overlay.grid_service = grid_service
	rails_overlay.rail_service = rail_service
	cities_overlay.grid_service = grid_service
	cities_overlay.cities_manager = cities_manager

	# Services
	#player_train.grid_service = grid_service
	

	# Controllers
	camera_controller.grid_service = grid_service

func _wire_signals() -> void:
	#player_train.tile_changed.connect(_on_player_train_tile_changed)
	train_manager.train_reached_city.connect(_on_train_reached_city)
#endregion

#region Map Loading
func _load_map(map_name: String) -> void:
	var map_path = "res://scenes/maps/%s.tscn" % map_name
	if not ResourceLoader.exists(map_path):
		push_error("Map not found for map: %s at path: %s" % [map_name, map_path])
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
	grid_service.map_size = new_map.get_node("Terrain").get_used_rect().size

	rail_service.rails_tilemap = $MapRoot/World1/Rails
	
	_build_rails_from_map(new_map.get_node("Rails"))
	_build_bridges_from_map(new_map.get_node("Bridges"))
	_spawn_cities_from_map(new_map.get_node("CitiesIds"))
	_spawn_trains_from_map(new_map.get_node("Trains"))
	_spawn_wagons()

func _spawn_cities_from_map(cities_ids_tilemap: TileMapLayer) -> void:
	for tile in cities_ids_tilemap.get_used_cells():
		var atlas_coords = cities_ids_tilemap.get_cell_atlas_coords(tile)
		var city_id = atlas_coords.y * 10 + atlas_coords.x
		cities_manager.spawn_city(city_id, tile)

# TODO: Orientation and team should not be hardcoded
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
		
		rail_service.spawn_rail(tile, atlas_coords)

func _build_bridges_from_map(bridges_tilemap: TileMapLayer) -> void:
	for tile in bridges_tilemap.get_used_cells():
		var atlas_coords = bridges_tilemap.get_cell_atlas_coords(tile)
		var source_id = bridges_tilemap.get_cell_source_id(tile)
		
		rail_service.spawn_bridge(tile, atlas_coords)


	#bridges_overlay.update()

# spawns wagons that can be picked by the train
func _spawn_wagons():
	var wagon = WAGON_SCENE.instantiate()

	# dependency injection
	wagon.grid_service = grid_service

	var tile_pos_ = Vector2i(20, 8)
	var ori_ = "E"
	var current_pos = grid_service.tile_to_world(tile_pos_)
	wagon.set_pos(current_pos)
	wagon.call_deferred("set_orientation", ori_)
	
	# add to container
	wagon_container.add_child(wagon)
#endregion

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_local_mouse_position()
		var tile = grid_service.world_to_tile(mouse_pos)
		print("Mouse pos: %s, tile: %s" % [mouse_pos, tile])
		if rail_service.has_rail(tile):
			print("Clicked a rail")
			if rail_service.has_junction(tile):
				print(" which is also a junction")
				rail_service.change_junction(tile)
	# if event is InputEventKey:
	# 	if event.as_text_keycode() == "Ctrl":
	if Input.is_action_just_pressed("ctrl"):
		_handle_gear_toggle()
	if Input.is_action_just_pressed("shift"):
		_handle_reverse_train()
	
func _handle_gear_toggle() -> void:
	train_manager.gear_toggle()

func _handle_reverse_train() -> void:
	train_manager.reverse_player_train()

func recenter_player_train():
	train_manager.recenter_player_train()

func reverse_player_train_direction():
	train_manager.reverse_player_train()


func _on_train_reached_city(city_name: String):
	print("Nav Scene: Train reached city %s" % city_name)
	# Fade out travel music before entering the city scene.
	AudioService.stop_music(1.5)
	QuestManager.notify_city_reached(city_name)
	SceneManager.enter_city(city_name)
