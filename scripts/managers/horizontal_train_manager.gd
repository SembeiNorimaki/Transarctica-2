extends Node
class_name HorizontalTrainManager


#Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService
var train_inventory: TrainInventory

#var wagons := {"Player": [], "Enemy": []}

var player_train: HorizontalTrain = null
var enemy_train: HorizontalTrain = null

const horizontal_train_scene = preload("res://scenes/entities/trains/horizontal_train.tscn")


func gear_up():
    player_train.gear_up()
func gear_down():
    player_train.gear_down()


# check GameState._player_train_state  for an example of train_data
func spawn_train(tile_pos: Vector2i, train_data: Dictionary) -> HorizontalTrain:
    var horizontal_train = horizontal_train_scene.instantiate()
    var initial_pos = grid_service.tile_to_world(tile_pos)
    horizontal_train.position = initial_pos

    # Dependecy injection
    horizontal_train.grid_service = grid_service
    horizontal_train.train_inventory = train_inventory

    # add wagons to train
    for wagon_data in train_data.wagons:
        horizontal_train.add_wagon(wagon_data)
    
    # TODO: add additional information about train: id, owner, fuel, max_speed, ....
    if train_data.owner == "Player":
        player_train = horizontal_train
    elif train_data.owner == "Enemy":
        enemy_train = horizontal_train
    
    return horizontal_train
        

func _on_wagon_resource_type_changed(wagon_index: int, resource: String):
    print("Wagon %d now holds: %s" % [wagon_index, resource])
    player_train.set_wagon_resource_type(wagon_index, resource)

func _on_wagon_resource_amount_changed(wagon_index: int, resource: String, qty: int):
    print("Wagon %d now holds: %d %s" % [wagon_index, qty, resource])
    player_train.set_wagon_resource_qty(wagon_index, qty)

func _on_train_money_changed(money: int):
    pass
    # display money in the locomotive label
    #wagons.Player[0].set_money(money)


# checks if any of the wagons in the train is clicked, returns the id of the clicked wagon or -1
func check_wagon_click(mouse_pos) -> int:
    var id = 0
    var result = player_train.check_wagon_click(mouse_pos)
    return result
    #for wagon in wagons.Player:
    #    var result = wagon.check_click(mouse_pos)
    #    if result:
    #        return id
    #    id += 1
    #return -1
        

# # resouce management (probably should be moved to a dedicated service)
# func add_resource_amount(resource_name_: String, qty_: int):
#     if resources.has(resource_name_):
#         resources[resource_name_] += qty_
#     else:
#         resources[resource_name_] = qty_

# func remove_resource_amount(resource_name_: String, qty_: int):
#     if resources.has(resource_name_):
#         resources[resource_name_] -= qty_
    
# func get_storage_capacity(resource_name_: String) -> int:
#     if available_storage.has(resource_name_):
#         return available_storage[resource_name_]
#     return 0

# func get_available_qty(resource_name_: String) -> int:
#     if resources.has(resource_name_):
#         return resources[resource_name_]
#     return 0

# func spawn_trainOLD(tile_pos: Vector2, owner: String) -> HorizontalTrain:
#     var horizontal_train = horizontal_train_scene.instantiate()
#     #horizontal_train.position = Vector2i(0, 200)
#     var initial_pos = grid_service.tile_to_world(tile_pos)
#     horizontal_train.position = initial_pos
#     print("Initial pos", initial_pos)

#     # Dependecy injection
#     horizontal_train.grid_service = grid_service
#     horizontal_train.train_resource_container = train_resource_container

#     # add wagons to train
#     for wagon_data in GameState.state.train.wagons:
#         horizontal_train.add_wagon(wagon_data)

#     if owner == "Player":
#         player_train = horizontal_train
#     elif owner == "Enemy":
#         enemy_train = horizontal_train

#     return horizontal_train
    
    # var wagon_position = grid_service.tile_to_world(tile_pos)
    # print("Wagon position: %s" % wagon_position)

    # var i = 0
    
    # for wagon_data in GameState.state.train.wagons:
    #     var wagon_type_ = wagon_data.wagon_name
    #     var cargo = wagon_data.cargo
    #     var resource_name = ""
    #     var resource_qty = 0
    #     if cargo:
    #         resource_name = cargo[0].resource_name
    #         resource_qty = cargo[0].resource_qty
    #         print("Initializing %s wagon with %s units of %s" % [wagon_type_, resource_qty, resource_name])
        
    #     var wagon_info = WagonTypes.TYPES[wagon_type_]
    #     var team = wagon_info.team

    #     if i > 0:
    #         wagon_position -= Vector2(wagon_info.size.x / 2, 0)

    #     var id = "w%s%s" % [team[0], next_wagon_id[team]] # Player wagon with id=3 -> wP3
    #     next_wagon_id[team] += 1

    #     var wagon = wagon_info.scene.instantiate()
        
    #     # Dependecy injection
    #     #wagon.wagon_manager = self
    #     wagon.grid_service = grid_service

    #     #wagon.call_defered("initialize", id, team)
    #     wagon.position = wagon_position
    #     wagon.call_deferred("set_resource_type", resource_name)
    #     wagon.call_deferred("set_resource_qty", resource_qty)
    #     #wagon.current_tile = tile_pos

    #     # Add to scene tree
    #     get_node("../../Containers/Wagons").add_child(wagon)
        
    #     train_resource_container.add_wagon(wagon_type_, resource_name, resource_qty)
        
    #     wagon_position -= Vector2(wagon_info.size.x / 2, 0)
    #     i += 1
