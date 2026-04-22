extends Control
class_name TradeScene


var resource_name_to_atlas_coords = {
	"alcohol": Vector2i(0, 0),
	"antiques": Vector2i(1, 0),
	"missiles": Vector2i(2, 0),
	"bricks": Vector2i(0, 1),
	"caviar": Vector2i(1, 1),
	"oil": Vector2i(2, 1),
	"earth": Vector2i(0, 2),
	"coal": Vector2i(1, 2),
	"plants": Vector2i(2, 2),
	"copper": Vector2i(0, 3),
	"dung": Vector2i(1, 3),
	"rails": Vector2i(2, 3),
	"fish": Vector2i(0, 4),
	"rods": Vector2i(1, 4),
	"salt": Vector2i(2, 4),
	"furs": Vector2i(0, 5),
	"gasoline": Vector2i(1, 5),
	"inspection": Vector2i(2, 5),
	"gray": Vector2i(0, 6),
	"meat": Vector2i(1, 6),
	"wood": Vector2i(2, 6)
}
var atlas_coords_to_resource_name = {
	Vector2i(0, 0): "alcohol",
	Vector2i(1, 0): "antiques",
	Vector2i(2, 0): "missiles",
	Vector2i(0, 1): "bricks",
	Vector2i(1, 1): "caviar",
	Vector2i(2, 1): "oil",
	Vector2i(0, 2): "earth",
	Vector2i(1, 2): "coal",
	Vector2i(2, 2): "plants",
	Vector2i(0, 3): "copper",
	Vector2i(1, 3): "dung",
	Vector2i(2, 3): "rails",
	Vector2i(0, 4): "fish",
	Vector2i(1, 4): "rods",
	Vector2i(2, 4): "salt",
	Vector2i(0, 5): "furs",
	Vector2i(1, 5): "gasoline",
	Vector2i(2, 5): "inspection",
	Vector2i(0, 6): "gray",
	Vector2i(1, 6): "meat",
	Vector2i(2, 6): "wood"
}

# Managers
@onready var horizontal_train_manager = $Managers/HorizontalTrainManager
@onready var resource_manager = $Managers/ResourceManager

# Containers
@onready var resources_container = $Containers/Resources

# Controllers

# Services
@onready var tile_occupancy_service = $Services/TileOccupancyService
@onready var grid_service = $Services/GridService

# Overlays

# Labels

# Map 
@onready var map_root = $MapRoot

var city_data = {
	"resources": {
		"caviar": 2,
		"alcohol": 5
	}
}
var resource_spawn_tiles = [Vector2i(0, 0), Vector2i(0, 1)]


#region initialization
func _ready() -> void:
	_inject_services()
	_load_map("level_1")
	initialize({})

func initialize(city_data_):
	

	#city_data = city_data_
	return

	
	var resource_tileset = map_root.get_node("TradeCity").get_node("Resources")
	
	var idx = 0
	for resource_name in city_data["resources"].keys():
		var qty = city_data["resources"][resource_name]
		var tile = resource_spawn_tiles[idx]
		for i in range(qty):
			resource_tileset.set_cell(tile, 0, resource_name_to_atlas_coords[resource_name])
			tile += Vector2i(1, 0)
		idx += 1
	
	print("Trade scene initialize with data: ", city_data)

func _inject_services():
	# Managers
	horizontal_train_manager.tile_occupancy_service = tile_occupancy_service
	horizontal_train_manager.grid_service = grid_service
	resource_manager.grid_service = grid_service
	resource_manager.tile_occupancy_service = tile_occupancy_service
	
#endregion

#region Map Loading
func _load_map(map_name: String) -> void:
	grid_service.set_tile_size(Vector2i(128, 64))
	_spawn_train(Vector2(5, 3))
	_spawn_resources()


func _spawn_resources():
	var idx = 0
	for resource_name in city_data["resources"].keys():
		var qty = city_data["resources"][resource_name]
		var tile = resource_spawn_tiles[idx]

		resource_manager.spawn_resource(tile, resource_name, qty)
		idx += 1



func _spawn_train(initial_tile: Vector2):
	horizontal_train_manager.spawn_train(initial_tile)

#endregion

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_local_mouse_position()
		var tile = grid_service.world_to_tile(mouse_pos)
		_handle_click(tile, event.button_index)
	
func _handle_click(tile, button_index):
	print("Clicked tile %s" % tile)

	# check if the tile has a reasource
