extends Node
class_name TradeService


func buy(city: CityResourceContainer, train: TrainResourceContainer, resource: String, qty: int) -> bool:
	# 1: Price lookup
	var price_per_unit = city.get_buy_price(resource)
	var total_cost = price_per_unit * qty

	# 2: City must have enough resources
	if qty > city.get_available_qty(resource):
		print("City has not enough resources")
		return false
	
	# 3: Train must have enough money
	if not train.has_money(total_cost):
		print("Train has not enough money")
		return false
	
	# 4: Train must have enough capacity
	if qty > train.get_storage_capacity(resource):
		print("Train has not enough storage capacity")
		return false
	
	# 5: Perform transaction
	train.remove_money(total_cost)
	city.remove_resource_amount(resource, qty)
	train.add_resource_amount(resource, qty)
	return true

func sell(city: CityResourceContainer, train: TrainResourceContainer, resource: String, qty: int) -> bool:
	# 1. Price lookup
	var price_per_unit = city.get_sell_price(resource)
	var total_gain = price_per_unit * qty

	# 2. Train must have enough resources
	if qty > train.get_available_qty(resource):
		print("Train does not have enough ", resource)
		return false

	# 3. City must have capacity
	if qty > city.get_storage_capacity(resource):
		print("City lacks storage capacity")
		return false

	# 4. Perform transaction
	train.add_money(total_gain)
	train.remove_resource_amount(resource, qty)
	city.add_resource_amount(resource, qty)

	return true


	
	

# func transfer(from: IResourceContainer, to: IResourceContainer, resource_name: String, qty: int) -> bool:
#     if qty > from.get_available_qty(resource_name):
#         print("Error: source does not have enough")
#         return false

#     if qty > to.get_storage_capacity(resource_name):
#         print("Error: destination lacks capacity")
#         return false

#     from.remove_resource_amount(resource_name, qty)
#     to.add_resource_amount(resource_name, qty)
#     return true


# func buy_resource(resource_name_: String, qty_: int) -> bool:
# 	var avail_qty = resource_manager.get_available_qty(resource_name_)
# 	if qty_ > avail_qty:
# 		print("Error, attempted to buy more resources than city available amount")
# 		return false
	
# 	var storage_capacity = horizontal_train_manager.get_storage_capacity(resource_name_)
# 	if qty_ > storage_capacity:
# 		print("Error, attempted to buy more resources than train storage capacity")
# 		return false
	
# 	resource_manager.remove_resource_amount(resource_name_, qty_)
# 	horizontal_train_manager.add_resource_amount(resource_name_, qty_)
# 	return true

# func sell_resource(resource_name_: String, qty_: int):
# 	var avail_qty = horizontal_train_manager.get_available_qty(resource_name_)
# 	if qty_ > avail_qty:
# 		print("Error, attempted to sell more resources than train available amount")
# 		return false
	
# 	var storage_capacity = resource_manager.get_storage_capacity(resource_name_)
# 	if qty_ > storage_capacity:
# 		print("Error, attempted to sell more resources than city storage capacity")
# 		return false
	
# 	horizontal_train_manager.remove_resource_amount(resource_name_, qty_)
# 	resource_manager.add_resource_amount(resource_name_, qty_)
# 	return true
