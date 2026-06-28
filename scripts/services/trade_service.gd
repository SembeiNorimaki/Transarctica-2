extends Node
class_name TradeService

@onready var city_inventory: CityInventory = $CityInventory
@onready var train_inventory: TrainInventory = $TrainInventory
@onready var loader_inventory: LoaderInventory = $LoaderInventory


func transfer_from_city_to_loader(resource_name: String, qty: int) -> bool:
    if resource_name == "":
        # print("Error: Resource name is empty")
        return false
    
    if loader_inventory.is_full():
        # print("Error: Loader inventory is full")
        return false
    
    var available_qty = city_inventory.get_available_qty(resource_name)
    if available_qty < qty:
        # print("Error: insufficient %s " % resource_name)
        return false

    var price_per_unit = city_inventory.get_buy_price(resource_name)

    var money = GameState.get_money()
    if money < price_per_unit * qty:
        # print("Error, not enough money")
        return false

    var success = loader_inventory.pick_from_city(resource_name, qty)
    if not success:
        # print("Error picking crate")
        return false

    city_inventory.remove_resource_amount(resource_name, qty)
    # print("Price per unit: ", price_per_unit)
    GameState.subtract_money(price_per_unit * qty)
    return true

func transfer_from_loader_to_city(resource_name: String, qty: int) -> bool:
    if resource_name == "":
        # print("Error: Resource name is empty")
        return false

    # Must match resource rules
    if resource_name != loader_inventory.get_resource_type():
        # print("Error: Resources don't match")
        return false

    # Check city capacity
    if qty > city_inventory.get_storage_capacity(resource_name):
        # print("Error: City has not enough storage capacity")
        return false

    var price_per_unit = city_inventory.get_sell_price(resource_name)

    # Move crate from loader to wagon
    loader_inventory.finalize_into_city(qty)
    city_inventory.add_resource_amount(resource_name, qty)
    # print("Price per unit: ", price_per_unit)
    GameState.add_money(price_per_unit * qty)
    return true

func transfer_from_train_to_loader(wagon_idx: int, qty: int) -> bool:
    if wagon_idx == -1:
        # print("Error: Wagon index is -1")
        return false

    if loader_inventory.is_full():
        # print("Error: Loader inventory is full")
        return false

    var resource_name = train_inventory.get_wagon_current_resource(wagon_idx)
    if resource_name == "":
        # print("Error: Wagon is empty")
        return false

    # Remove crate from wagon
    var removed = train_inventory.remove_resource_qty_from_wagon(wagon_idx, qty)
    if not removed:
        # print("Error removing resource from train")
        return false

    loader_inventory.pick_from_wagon(resource_name, qty)
    
    return true

func transfer_from_loader_to_train(wagon_idx: int, qty: int) -> bool:
    if wagon_idx == -1:
        # print("Error: Wagon index is -1")
        return false
    
    if loader_inventory.is_empty():
        # print("Error: Loader inventory is empty")
        return false
    
    var resource_name = loader_inventory.get_resource_type()
    # Must match wagon rules
    if not train_inventory.wagon_can_store(wagon_idx, resource_name):
        # print("Error, this wagon cannot store %s" % resource_name)
        return false
    
    loader_inventory.finalize_into_wagon(qty)
    train_inventory.add_resource_qty_to_wagon(wagon_idx, resource_name, qty)
    return true
