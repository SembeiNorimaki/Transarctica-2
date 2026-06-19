extends Node
class_name CityInventory

# resources example:
# resources := {
#     "wood": {"qty": 50, "buy_price": 3, "sell_price": 2, "max_capacity": 200},
#     "iron": {"qty": 10, "buy_price": 8, "sell_price": 6, "max_capacity": 50}
# }

var resources := {}
var city_name := ""

signal city_resource_amount_changed(resource_name: String, qty: int)

func initialize_resource(resource_name, qty, buy_price, sell_price, max_capacity):
	resources[resource_name] = {
		"resource_name": resource_name,
		"qty": qty,
		"buy_price": buy_price,
		"sell_price": sell_price,
		"max_capacity": max_capacity
	}

func get_all_info() -> Dictionary:
	return resources

func get_resource_info(resource_name: String) -> Dictionary:
	return resources[resource_name]

func get_available_qty(resource_name: String) -> int:
	if not resources.has(resource_name):
		return 0
	return resources[resource_name].get("qty", 0)

func get_buy_price(resource_name: String) -> int:
	if not resources.has(resource_name):
		return 0
	return resources[resource_name].get("buy_price", 0)

func get_sell_price(resource_name: String) -> int:
	if not resources.has(resource_name):
		return 0
	return resources[resource_name].get("sell_price", 0)

func get_storage_capacity(resource_name: String) -> int:
	if not resources.has(resource_name):
		return 0
	var info = resources[resource_name]
	return info.get("max_capacity", 0) - info.get("qty", 0)

func add_resource_amount(resource_name: String, qty: int) -> bool:
	if not resources.has(resource_name):
		return false
	print("Adding %s units of %s to city" % [qty, resource_name])
	resources[resource_name].qty += qty
	GameState.add_goods_to_city(city_name, resource_name, qty)
	city_resource_amount_changed.emit(resource_name, resources[resource_name].qty)
	return true

func remove_resource_amount(resource_name: String, qty: int) -> bool:
	if not resources.has(resource_name):
		return false
	print("Removing %s units of %s from city" % [qty, resource_name])
	resources[resource_name].qty -= qty
	GameState.remove_goods_from_city(city_name, resource_name, qty)
	city_resource_amount_changed.emit(resource_name, resources[resource_name].qty)
	return true
