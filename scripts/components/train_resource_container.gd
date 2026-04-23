extends Node
class_name TrainResourceContainer

# resources example:
# resources := {
#     "wood": {"qty": 50, "buy_price": 3, "sell_price": 2, "max_capacity": 200},
#     "iron": {"qty": 10, "buy_price": 8, "sell_price": 6, "max_capacity": 50}
# }

var resources := {}

var money = 1000

func initialize_resource(resource, qty, max_capacity):
    resources[resource] = {
        "qty": qty, 
        "max_capacity": max_capacity
    }

func get_all_info() -> Dictionary:
    return resources

func has_money(total_cost: int):
    return total_cost <= money

func add_money(amount: int):
    money += amount

func remove_money(amount: int):
    money -= amount

func get_available_qty(resource: String) -> int:
    if not resources.has(resource):
        return 0
    return resources[resource].get("qty", 0)

func get_storage_capacity(resource: String) -> int:
    if not resources.has(resource):
        return 0
    var info = resources[resource]
    return info.get("max_capacity", 0) - info.get("qty", 0)

func add_resource_amount(resource: String, qty: int) -> bool:
    if not resources.has(resource):
        return false
    print("Adding %s units of %s to train" % [qty, resource])
    resources[resource]["qty"] += qty
    return true

func remove_resource_amount(resource: String, qty: int) -> bool:
    if not resources.has(resource):
        return false
    print("Removing %s units of %s from train" % [qty, resource])
    resources[resource]["qty"] -= qty
    return true

