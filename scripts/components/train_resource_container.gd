extends Node
class_name TrainResourceContainer

# resources example:
# resources := {
#     "wood": {"qty": 50, "buy_price": 3, "sell_price": 2, "max_capacity": 200},
#     "iron": {"qty": 10, "buy_price": 8, "sell_price": 6, "max_capacity": 50}
# }

var resources := {}
var wagons := []

var money: int

func _ready() -> void:
	money = GameState.state.money
	
signal wagon_resource_type_changed(wagon_index: int, resource: String)
signal wagon_resource_amount_changed(wagon_index: int, resource: String, qty: int)
signal train_money_changed(money: int)

const RESOURCE_WAGON_TYPE := {
	"caviar": "MerchandiseWagon",
	"alcohol": "MerchandiseWagon",
	"wood": "MerchandiseWagon",
	"iron": "MerchandiseWagon",
	"coal": "TenderWagon",
	"oil": "TankerWagon",
	"water": "TankerWagon"
}

const WAGON_CAPACITIES := {
	"LocomotiveWagon": 0,
	"TenderWagon": 60,
	"MerchandiseWagon": 2,
	"ContainerWagon": 2,
	"GondolaWagon": 50,
	"BarracksWagon": 0,
	"CannonWagon": 0,
	"TankerWagon": 80,
	"TimberWagon": 20
}

func add_wagon(wagon_type: String, cargo: String = "", qty: int = 0) -> void:
	print("Adding wagon %s with %s units of %s" % [wagon_type, qty, cargo])
	wagons.append(create_wagon(wagon_type, cargo, qty))


func create_wagon(wagon_type: String, cargo: String, qty: int) -> Dictionary:
	return {
		"wagon_type": wagon_type,
		"max_capacity": WAGON_CAPACITIES[wagon_type],
		"qty": qty,
		"resource_name": cargo
	}
	

# func initialize_resource(resource, qty, max_capacity):
# 	resources[resource] = {
# 		"qty": qty,
# 		"max_capacity": max_capacity
# 	}


# func get_all_info() -> Dictionary:
# 	return resources

func get_wagon_count() -> int:
	return wagons.size()

func get_wagon_info(idx: int) -> Dictionary:
	return wagons[idx]

func get_wagon_type(idx: int) -> String:
	return wagons[idx].wagon_type

func get_wagon_capacity(idx: int) -> int:
	return wagons[idx].max_capacity

func get_wagon_current_resource(idx: int) -> String:
	return wagons[idx].resource_name

func get_wagon_resource_qty(idx: int) -> int:
	return wagons[idx].qty

func get_wagon_free_space(idx: int) -> int:
	return wagons[idx].max_capacity - wagons[idx].qty

func wagon_can_store(wagon_idx: int, resource_name: String) -> bool:
	var wagon = wagons[wagon_idx]
	var needed_type = RESOURCE_WAGON_TYPE.get(resource_name, null)

	if needed_type == null:
		return false

	if wagon.wagon_type != needed_type:
		return false

	# empty wagon → can store any resource of its type
	if wagon.resource_name == "":
		return true

	# wagon already storing something → must match
	return wagon.resource_name == resource_name

func get_wagons_idx_that_can_store(resource_name: String) -> Array:
	var result := []
	for i in range(wagons.size()):
		if wagon_can_store(i, resource_name):
			result.append(i)
	return result

func get_wagon_capacity_for_resource(wagon_idx: int, resource_name: String) -> int:
	if not wagon_can_store(wagon_idx, resource_name):
		return 0
	return get_wagon_free_space(wagon_idx)

# region money
func has_money(total_cost: int):
	return total_cost <= money

func add_money(amount: int):
	money += amount
	GameState.state.money = money
	GameState.save()
	QuestManager.notify_money_changed(money)
	emit_signal("train_money_changed", money)

func remove_money(amount: int):
	money -= amount
	GameState.state.money = money
	GameState.save()
	QuestManager.notify_money_changed(money)
	emit_signal("train_money_changed", money)

#endregion


# # region queries about the whole train, not just a specific wagon
# func get_total_train_qty_of(resource_name: String) -> int:
# 	var total := 0
# 	for wagon in wagons:
# 		total += wagon.qty
# 	return total

# func get_storage_capacity(resource: String) -> int:
# 	var needed_wagon_type = RESOURCE_WAGON_TYPE.get(resource, null)
# 	print("%s needs a %s wagon" % [resource, needed_wagon_type])
# 	if needed_wagon_type == null:
# 		return 0

# 	var total := 0
# 	for wagon in wagons:
# 		print("Wagon type: %s" % wagon.wagon_type)
# 		
# 		# Wagon must be the correct type
# 		if wagon.wagon_type != needed_wagon_type:
# 			continue
# 		print("correct wagon type found: %s" % wagon.wagon_type)
# 		
# 		# Wagon must be empty or already storing this resource
# 		if wagon.resource_name != "" and wagon.resource_name != resource:
# 			continue

# 		print("wagon empty or already storing %s" % resource)

# 		# compute free space
# 		var used = wagon.qty

# 		total += wagon.max_capacity - used

# 	return total

func add_resource_qty_to_wagon(wagon_idx: int, resource_name: String, qty: int) -> void:
	if wagon_can_store(wagon_idx, resource_name):
		if get_wagon_free_space(wagon_idx) >= qty:
			if get_wagon_current_resource(wagon_idx) == "":
				wagons[wagon_idx].resource_name = resource_name
				emit_signal("wagon_resource_type_changed", wagon_idx, resource_name)
			wagons[wagon_idx].qty += qty
			emit_signal("wagon_resource_amount_changed", wagon_idx, resource_name, wagons[wagon_idx].qty)
			GameState.update_wagon_cargo(wagon_idx, wagons[wagon_idx].resource_name, wagons[wagon_idx].qty)
			QuestManager.notify_goods_collected(resource_name, wagons[wagon_idx].qty)


func remove_resource_qty_from_wagon(wagon_idx: int, qty: int) -> void:
	if get_wagon_resource_qty(wagon_idx) >= qty:
		wagons[wagon_idx].qty -= qty
		emit_signal("wagon_resource_amount_changed", wagon_idx, wagons[wagon_idx].resource_name, wagons[wagon_idx].qty)
		var old_res = wagons[wagon_idx].resource_name
		if get_wagon_resource_qty(wagon_idx) == 0:
			wagons[wagon_idx].resource_name = ""
			emit_signal("wagon_resource_type_changed", wagon_idx, "")
		GameState.update_wagon_cargo(wagon_idx, wagons[wagon_idx].resource_name, wagons[wagon_idx].qty)
		QuestManager.notify_goods_collected(old_res, wagons[wagon_idx].qty)
