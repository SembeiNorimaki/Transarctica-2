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

#Controllers
@onready var camera_controller = $Controllers/CameraController

# Map 
@onready var map_root = $MapRoot
@onready var exploration_layer = $MapRoot/ExplorationLayer

#Entities
@onready var player_train = $Containers/Trains/PlayerTrain

# Containers
@onready var trains_container = $Containers/Trains
@onready var city_labels_container = $Containers/CityLabels


func _ready() -> void:
	grid_service.set_tile_size(Vector2i(128, 64))
	_inject_services()
	call_deferred("_wire_signals")
	_load_map("world_1")

	camera_controller.center_at_tile(Vector2i(15, 5))
	camera_controller.set_zoom(1.0)

func _inject_services():
	# Managers
	train_manager.grid_service = grid_service
	train_manager.rail_service = rail_service
	train_manager.cities_manager = cities_manager
	train_manager.exploration_layer = exploration_layer
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

func _wire_signals():
	#player_train.tile_changed.connect(_on_player_train_tile_changed)
	train_manager.train_reached_city.connect(_on_train_reached_city)
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

	rail_service.rails_tilemap = $MapRoot/World1/Rails
	
	_build_rails_from_map(new_map.get_node("Rails"))
	_spawn_cities_from_map(new_map.get_node("CitiesIds"))
	_spawn_trains_from_map(new_map.get_node("Trains"))

	
func _spawn_cities_from_map(cities_ids_tilemap: TileMapLayer) -> void:
	for tile in cities_ids_tilemap.get_used_cells():
		var atlas_coords = cities_ids_tilemap.get_cell_atlas_coords(tile)
		var city_id = atlas_coords.y * 10 + atlas_coords.x
		cities_manager.spawn_city(city_id, tile)

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
	
	#rails_overlay.update()


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
	
func _handle_gear_toggle():
	train_manager.gear_toggle()

func _handle_reverse_train():
	train_manager.reverse_train()




func _on_player_train_tile_changed(from_tile: Vector2i, to_tile: Vector2i) -> void:
	print("Train changed tile")
	pass
	#rail_service.build_rail(to_tile)

func _on_train_reached_city(city_name: String):
	print("Nav Scene: Train reached city %s" % city_name)
	SceneManager.enter_city(city_name)

func recenter_player_train():
	train_manager.recenter_player_train()
func reverse_player_train_direction():
	train_manager.reverse_player_train_direction()
