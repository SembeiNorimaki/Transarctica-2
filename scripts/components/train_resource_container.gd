extends Node
class_name TrainResourceContainer

var resources := {}
var max_capacity := {}

func get_available_qty(resource: String) -> int:
    return resources.get(resource, 0)

func get_storage_capacity(resource: String) -> int:
    return max_capacity.get(resource, 0) - get_available_qty(resource)

func add_resource_amount(resource: String, qty: int) -> void:
    resources[resource] = get_available_qty(resource) + qty
    
func remove_resource_amount(resource: String, qty: int) -> void:
    resources[resource] = get_available_qty(resource) - qty
