extends Node
class_name IResourceContainer

func get_available_qty(resource_name: String) -> int:
    return 0

func get_storage_capacity(resource_name: String) -> int:
    return 0

func add_resource_amount(resource_name: String, qty: int) -> void:
    pass

func remove_resource_amount(resource_name: String, qty: int) -> void:
    pass