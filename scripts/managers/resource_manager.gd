extends Node
class_name ResourceManager

# Injected by TradeScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService

# resouce management (probably should be moved to a dedicated service)
var resources = {
	"alcohol": 3, 
	"caviar": 2
}

var max_capacities = {
	"alcohol": 300,
	"caviar": 200    
}

var available_storage = {
	"alcohol": 297,
	"caviar": 198
}

var RESOURCE_SCENE = preload("res://scenes/entities/resources/resource.tscn")

func _ready() -> void:
	pass

#region resource spawning
func spawn_resource(tile_pos: Vector2i, resource_name_: String, qty_: int) -> void:
	var resource = RESOURCE_SCENE.instantiate()
	
	resource.call_deferred("set_type", resource_name_)
	resource.call_deferred("set_qty", qty_)
	var screen_pos = grid_service.tile_to_world(tile_pos)	
	resource.position = screen_pos
		

	# Dependency injection

	# Add to scene tree
	get_node("../../Containers/Resources").add_child(resource)

	# Register in occupancy
	tile_occupancy_service.register(tile_pos, resource)

#endregion

# resouce management (probably should be moved to a dedicated service)
func add_resource_amount(resource_name_: String, qty_: int):
	if resources.has(resource_name_):
		resources[resource_name_] += qty_
	else:
		resources[resource_name_] = qty_

func remove_resource_amount(resource_name_: String, qty_: int):
	if resources.has(resource_name_):
		resources[resource_name_] -= qty_
	
func get_storage_capacity(resource_name_: String) -> int:
	if available_storage.has(resource_name_):
		return available_storage[resource_name_]
	return 0

func get_available_qty(resource_name_: String) -> int:
	if resources.has(resource_name_):
		return resources[resource_name_]
	return 0
