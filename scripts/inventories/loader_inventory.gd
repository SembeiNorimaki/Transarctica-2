extends Node
class_name LoaderInventory

var resource_name := ""
var origin := "" # "city" or "wagon"
var crate_count := 0
#var total_cost_paid := 0

var max_crates := 12

func is_empty() -> bool:
    return crate_count == 0

func is_full() -> bool:
    return crate_count == max_crates

func get_resource_type() -> String:
    return resource_name

func get_qty() -> int:
    return crate_count

func get_origin() -> String:
    return origin

func can_pick(resource_name_: String, from_origin: String) -> bool:
    # Loader empty can pick anything
    if is_empty():
        return true
    
    # Loader not empty -> must match resource and origin
    return resource_name_ == resource_name and from_origin == origin

func pick_from_city(resource_name_: String, qty: int) -> bool:
    if not can_pick(resource_name_, "city"):
        # print("Error, cannot pick from city")
        return false

    if crate_count + qty > max_crates:
        # print("Error, insufficient amount in city")
        return false

    # First pickup defines loader state
    if is_empty():
        resource_name = resource_name_
        origin = "city"

    crate_count += qty
    return true


func pick_from_wagon(resource_name_: String, qty: int) -> bool:
    if not can_pick(resource_name_, "wagon"):
        # print("Error, cannot pick from wagon")
        return false
    
    if is_empty():
        resource_name = resource_name_
        origin = "wagon"
        
    crate_count = min(crate_count + qty, max_crates)
    return true

func finalize_into_city(qty: int) -> void:
    qty = min(qty, crate_count)
    crate_count -= qty
    
    if is_empty():
        _reset()

func finalize_into_wagon(qty: int) -> void:
    qty = min(qty, crate_count)
    crate_count -= qty
    
    if is_empty():
        _reset()


# func undo_to_city(qty: int, price_per_crate: int, train_money: int) -> int:
#     # Returns updated train money
#     if origin != "city":
#         return train_money
    
#     qty = min(qty, crate_count)
#     var refund = qty * price_per_crate

#     crate_count -= qty
#     total_cost_paid -= refund
#     train_money += refund

#     if is_empty():
#         _reset()

#     return train_money

# func undo_to_wagon(qty: int) -> void:
#     qty = min(qty, crate_count)
#     crate_count -= qty
    
#     if is_empty():
#         _reset()


# func pick_from_cityOLD(resource: String, qty: int, price_per_crate: int, train_money: int) -> int:
#     # Returns updated train money
#     if not can_pick(resource, "city"):
#         return train_money

#     if crate_count + qty > max_crates:
#         qty = max_crates - crate_count

#     var cost = qty * price_per_crate
#     if cost > train_money:
#         return train_money # cannot afford
    
#     # First pickup defines loader state
#     if is_empty():
#         resource_type = resource
#         origin = "city"
    
#     crate_count += qty
#     total_cost_paid += cost
#     return train_money - cost


# func pick_from_wagonOLD(resource: String, qty: int) -> void:
#     if not can_pick(resource, "wagon"):
#         return
    
#     if is_empty():
#         resource_type = resource
#         origin = "wagon"
        
#     crate_count = min(crate_count + qty, max_crates)
    

func _reset() -> void:
    resource_name = ""
    origin = ""
    crate_count = 0
    #total_cost_paid = 0
