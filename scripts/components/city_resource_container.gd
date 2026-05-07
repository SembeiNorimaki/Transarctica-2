extends Node
class_name CityResourceContainer


# resources example:
# resources := {
#     "wood": {"qty": 50, "buy_price": 3, "sell_price": 2, "max_capacity": 200},
#     "iron": {"qty": 10, "buy_price": 8, "sell_price": 6, "max_capacity": 50}
# }

var resources := {}

signal city_resource_amount_changed(resource: String, qty: int)

func initialize_resource(resource, qty, buy_price, sell_price, max_capacity):
    resources[resource] = {
        "resource_name": resource,
        "qty": qty,
        "buy_price": buy_price,
        "sell_price": sell_price,
        "max_capacity": max_capacity
    }

func get_all_info() -> Dictionary:
    return resources

func get_resource_info(resource: String) -> Dictionary:
    return resources[resource]

func get_available_qty(resource: String) -> int:
    if not resources.has(resource):
        return 0
    return resources[resource].get("qty", 0)

func get_buy_price(resource: String) -> int:
    if not resources.has(resource):
        return 0
    return resources[resource].get("buy_price", 0)

func get_sell_price(resource: String) -> int:
    if not resources.has(resource):
        return 0
    return resources[resource].get("sell_price", 0)

func get_storage_capacity(resource: String) -> int:
    if not resources.has(resource):
        return 0
    var info = resources[resource]
    return info.get("max_capacity", 0) - info.get("qty", 0)

func add_resource_amount(resource: String, qty: int) -> bool:
    if not resources.has(resource):
        return false
    print("Adding %s units of %s to city" % [qty, resource])
    resources[resource].qty += qty
    emit_signal("city_resource_amount_changed", resource, resources[resource].qty)
    return true

func remove_resource_amount(resource: String, qty: int) -> bool:
    if not resources.has(resource):
        return false
    print("Removing %s units of %s from city" % [qty, resource])
    resources[resource].qty -= qty
    emit_signal("city_resource_amount_changed", resource, resources[resource].qty)
    return true
