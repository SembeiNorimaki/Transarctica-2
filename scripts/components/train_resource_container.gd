extends Node
class_name TrainResourceContainer

# resources example:
# resources := {
#     "wood": {"qty": 50, "buy_price": 3, "sell_price": 2, "max_capacity": 200},
#     "iron": {"qty": 10, "buy_price": 8, "sell_price": 6, "max_capacity": 50}
# }

var resources := {}
var wagons := []

var money: int = 1000

signal wagon_resource_type_changed(wagon_index: int, resource: String)
signal wagon_resource_amount_changed(wagon_index: int, resource: String, qty: int)


const RESOURCE_WAGON_TYPE := {
	"caviar": "merchandise",
	"alcohol": "merchandise",
	"wood": "merchandise",
	"iron": "merchandise",
	"coal": "tender",
	"oil": "tanker",
	"water": "tanker"
}

const WAGON_CAPACITIES := {
	"locomotive": 0,
	"tender": 60,
	"merchandise": 50,
	"gondola": 50,
	"barracks": 0,
	"cannon": 0,
	"tanker": 80
}

func add_wagon(wagon_type: String) -> void:
	wagons.append(create_wagon(wagon_type))

func create_wagon(wagon_type: String) -> Dictionary:
	return {
		"wagon_type": wagon_type,
		"max_capacity": WAGON_CAPACITIES[wagon_type],
		"resources": {},
		"current_type": null
	}
	

func initialize_resource(resource, qty, max_capacity):
	resources[resource] = {
		"qty": qty,
		"max_capacity": max_capacity
	}


func get_all_info() -> Dictionary:
	return resources

func get_wagon_count() -> int:
	return wagons.size()

func get_wagon_info(idx: int) -> Dictionary:
	return wagons[idx]

func get_wagon_type(idx: int) -> String:
	return wagons[idx].wagon_type

func get_wagon_capacity(idx: int) -> int:
	return wagons[idx].max_capacity

func get_wagon_current_resource(idx: int) -> String:
	return wagons[idx].current_type

func get_wagon_resources(idx: int) -> Dictionary:
	return wagons[idx].resources

func get_wagon_free_space(idx: int) -> int:
	var used := 0
	for qty in wagons[idx].resources.values():
		used += qty
	return wagons[idx].max_capacity - used

func wagon_can_store(i: int, resource: String) -> bool:
	var wagon = wagons[i]
	var needed_type = RESOURCE_WAGON_TYPE.get(resource, null)

	if needed_type == null:
		return false

	if wagon.wagon_type != needed_type:
		return false

	# empty wagon → can store any resource of its type
	if wagon.current_resource == null:
		return true

	# wagon already storing something → must match
	return wagon.current_resource == resource

func get_wagons_that_can_store(resource: String) -> Array:
	var result := []
	for i in range(wagons.size()):
		if wagon_can_store(i, resource):
			result.append(i)
	return result

func get_wagon_capacity_for_resource(i: int, resource: String) -> int:
	if not wagon_can_store(i, resource):
		return 0
	return get_wagon_free_space(i)

# region money
func has_money(total_cost: int):
	return total_cost <= money

func add_money(amount: int):
	money += amount

func remove_money(amount: int):
	money -= amount
#endregion

func get_available_qty(resource: String) -> int:
	var total := 0
	for wagon in wagons:
		total += wagon.resources.get(resource, 0)
	return total

func get_storage_capacity(resource: String) -> int:
	var needed_wagon_type = RESOURCE_WAGON_TYPE.get(resource, null)
	if needed_wagon_type == null:
		return 0

	var total := 0
	for wagon in wagons:
		# Wagon must be the correct type
		if wagon.wagon_type != needed_wagon_type:
			continue
		
		# Wagon must be empty or already storing this resource
		if wagon.current_type != null and wagon.current_type != resource:
			continue

		# compute free space
		var used := 0
		for qty in wagon.resources.values():
			used += qty

		total += wagon.max_capacity - used

	return total

func add_resource_amount(resource: String, qty: int) -> void:
	var needed_type = RESOURCE_WAGON_TYPE.get(resource, null)
	if needed_type == null:
		print("Cannot store resource: " + resource)
		return

	var remaining := qty
	var i := 0
	for wagon in wagons:
		if remaining <= 0:
			break
		
		# skip wagons of wrong type
		if wagon.wagon_type != needed_type:
			i += 1
			continue
		
		# skip wagons storing a different resource
		if wagon.current_type != null and wagon.current_type != resource:
			i += 1
			continue

		# determine wagon free space
		var used := 0
		for q in wagon.resources.values():
			used += q

		var free_space = wagon.max_capacity - used
		if free_space <= 0:
			i += 1
			continue

		# if wagon is empty, set its type to the current resource
		if wagon.current_type == null:
			print("Refurbishing wagon %d to store %s" % [i, resource])
			wagon.current_type = resource
			emit_signal("wagon_resource_changed", i, resource)
		
		var to_add = min(remaining, free_space)
		wagon.resources[resource] = wagon.resources.get(resource, 0) + to_add
		print("Adding %s units of %s to wagon %s" % [to_add, resource, i])
		emit_signal("wagon_resource_amount_changed", i, resource, wagon.resources[resource])
		remaining -= to_add
		i += 1

func remove_resource_amount(resource: String, qty: int) -> void:
	var remaining := qty
	var i := 0
	for wagon in wagons:
		if remaining <= 0:
			break

		var wagon_qty = wagon.resources.get(resource, 0)
		if wagon_qty <= 0:
			i += 1
			continue

		var to_remove = min(wagon_qty, remaining)
		wagon.resources[resource] = wagon_qty - to_remove
		print("Removing %s units of %s from wagon %s" % [to_remove, resource, i])
		emit_signal("wagon_resource_amount_changed", i, resource, wagon.resources[resource])
		remaining -= to_remove

		# If wagon becomes empty, unlock it
		if wagon.resources[resource] <= 0:
			wagon.resources.erase(resource)
			if wagon.resources.is_empty():
				wagon.current_type = null
				print("Wagon %d is now empty" % i)
				emit_signal("wagon_resource_changed", i, null)
		i += 1


func get_available_qty_OLD(resource: String) -> int:
	if not resources.has(resource):
		return 0
	return resources[resource].get("qty", 0)

func get_storage_capacity_OLD(resource: String) -> int:
	if not resources.has(resource):
		return 0
	var info = resources[resource]
	return info.get("max_capacity", 0) - info.get("qty", 0)

func add_resource_amount_OLD(resource: String, qty: int) -> bool:
	if not resources.has(resource):
		return false
	print("Adding %s units of %s to train" % [qty, resource])
	resources[resource]["qty"] += qty
	return true

func remove_resource_amount_OLD(resource: String, qty: int) -> bool:
	if not resources.has(resource):
		return false
	print("Removing %s units of %s from train" % [qty, resource])
	resources[resource]["qty"] -= qty
	return true
