extends Node
class_name ResourceManager

# Injected by TradeScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService

# # resouce management (probably should be moved to a dedicated service)
# var resources = {
#     "alcohol": 3,
#     "caviar": 2
# }

# var max_capacities = {
#     "alcohol": 300,
#     "caviar": 200
# }

# var available_storage = {
#     "alcohol": 297,
#     "caviar": 198
# }


var resource_spawn_tiles = {
    "missiles": Vector2i(-4, 10),
    "gasoline": Vector2i(-3, 9),
    "oil": Vector2i(-2, 8),
    "wolfmeat": Vector2i(-1, 7),
    "fishingrods": Vector2i(0, 6),
    "caviar": Vector2i(1, 5),
    "antiques": Vector2i(2, 4),
    "alcohol": Vector2i(3, 3),
    "mammothdung": Vector2i(4, 2),
    "fish": Vector2i(5, 1),
    "furs": Vector2i(6, 0),
    "salt": Vector2i(7, -1),
    "plants": Vector2i(8, -2),

}

var required_resource_spawn_tiles = [Vector2i(22, 19), Vector2i(22, 20), Vector2i(22, 21)]
var produced_resource_spawn_tiles = [Vector2i(3, 3), Vector2i(4, 2), Vector2i(5, 1)]


var idx = 0
var RESOURCE_SCENE = preload("res://scenes/entities/resources/resource.tscn")
var CRATE_SCENE = preload("res://scenes/entities/resources/crate.tscn")

var resources = {}

func _ready() -> void:
    pass

#region resource spawning
func spawn_crate(resource_name_: String, qty_: int, mode: String):
	# print("Spawning crate %s" % resource_name_)
	var crate = CRATE_SCENE.instantiate()
	crate.call_deferred("set_mode", "InGround")
	crate.call_deferred("set_qty", qty_)
	

    var tile = resource_spawn_tiles[resource_name_]
    # var tile = produced_resource_spawn_tiles[idx]
    # if mode == "required":
    #     tile = required_resource_spawn_tiles[idx]

    var screen_pos = grid_service.tile_to_world(tile)
    crate.position = screen_pos
    idx += 1

    # Dependency injection

    # Add to scene tree
    get_node("../../Containers/Resources").add_child(crate)

	# Register in occupancy
	# print("Resgistering crate %s to tile %s" % [resource_name_, tile])
	tile_occupancy_service.register(tile, crate)

    resources[resource_name_] = crate


func spawn_resource(resource_name_: String, qty_: int, mode: String) -> void:
	# print("Spawning resource %s" % resource_name_)
	var resource = RESOURCE_SCENE.instantiate()
	
	resource.call_deferred("set_type", resource_name_)
	resource.call_deferred("set_qty", qty_)
	var tile = produced_resource_spawn_tiles[idx]
	if mode == "required":
		tile = required_resource_spawn_tiles[idx]

    var screen_pos = grid_service.tile_to_world(tile)
    resource.position = screen_pos
    idx += 1
        

    # Dependency injection

    # Add to scene tree
    get_node("../../Containers/Resources").add_child(resource)

	# Register in occupancy
	# print("Resgistering resource %s to tile %s" % [resource_name_, tile])
	tile_occupancy_service.register(tile, resource)

    resources[resource_name_] = resource

#endregion


func xpos_to_resource_name(xpos: int) -> String:
	# print("Checking resource for x position: %s" % xpos)
	var i = 0
	for resource_name in resource_spawn_tiles.keys():
		var spawn_tile = resource_spawn_tiles[resource_name]
		var world_pos = grid_service.tile_to_world(spawn_tile)
		if abs(world_pos.x - xpos) < 50:
			return resource_name
		i += 1
	return ""
		
		
	# for i in range(resources.keys().size()):
	# 	print("Resource %s xpos: %s" % [resources.keys()[i], resources[resources.keys()[i]].global_position.x])
	# 	if abs(resources[resources.keys()[i]].global_position.x - xpos) < 50:
	# 		return i
	# return -1

func update_resource_qty(resource_name: String, qty_: int):
    var resource = resources[resource_name]
    resource.set_qty(qty_)


func get_resource_in_tile(tile: Vector2i):
    var resources = tile_occupancy_service.get_entities(tile)
    if resources.size() == 1:
        return resources[0]
