extends Node
class_name TradeService

var city: CityResourceContainer = null
var train: TrainResourceContainer = null

var resource_name: String = ""
var transaction_type: String = ""
var qty: int = 0
var price: int = 0

func set_transaction_data(resource_name_: String, transaction_type_: String, qty_: int, price_: int):
	resource_name = resource_name_
	transaction_type = transaction_type_
	qty = qty_
	price = price_

func execute_transaction(buttonIdx: int):
	if buttonIdx == 1:
		qty = 1
	elif buttonIdx == 2:
		qty = 10
	print("Executing transaction %s of %s units of %s" % [transaction_type, qty, resource_name])
	if transaction_type == "buy":
		buy(resource_name, qty)
	elif transaction_type == "sell":
		sell(resource_name, qty)

func set_context(city_container: CityResourceContainer, train_container: TrainResourceContainer):
	city = city_container
	train = train_container

func buy(resource: String, qty: int) -> bool:
	# 1: Price lookup
	var price_per_unit = price
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

func sell(resource: String, qty: int) -> bool:
	# 1. Price lookup
	var price_per_unit = price
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
