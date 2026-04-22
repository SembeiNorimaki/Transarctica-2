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

var resource_spawn_tiles = [Vector2i(0, 0), Vector2i(0, 1)]
var idx = 0
var RESOURCE_SCENE = preload("res://scenes/entities/resources/resource.tscn")

func _ready() -> void:
    pass

#region resource spawning
func spawn_resource(resource_name_: String, qty_: int) -> void:
    var resource = RESOURCE_SCENE.instantiate()
    
    resource.call_deferred("set_type", resource_name_)
    resource.call_deferred("set_qty", qty_)
    
    var tile = resource_spawn_tiles[idx]
    var screen_pos = grid_service.tile_to_world(tile)
    resource.position = screen_pos
    idx += 1
        

    # Dependency injection

    # Add to scene tree
    get_node("../../Containers/Resources").add_child(resource)

    # Register in occupancy
    print("Resgistering resource %s to tile %s" % [resource_name_, tile])
    tile_occupancy_service.register(tile, resource)

#endregion

func get_resource_in_tile(tile: Vector2i):
    var resources = tile_occupancy_service.get_entities(tile)
    if resources.size() == 1:
        return resources[0]