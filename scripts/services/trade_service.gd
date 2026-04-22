extends Node
class_name TradeService


func transfer(from: IResourceContainer, to: IResourceContainer, resource_name: String, qty: int) -> bool:
    if qty > from.get_available_qty(resource_name):
        print("Error: source does not have enough")
        return false

    if qty > to.get_storage_capacity(resource_name):
        print("Error: destination lacks capacity")
        return false

    from.remove_resource_amount(resource_name, qty)
    to.add_resource_amount(resource_name, qty)
    return true


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
