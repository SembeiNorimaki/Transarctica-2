extends Node
class_name HorizontalTrainManager


#Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService

var next_wagon_id = {"Player": 0, "Enemy": 0}
var wagons := {"Player": [], "Enemy": []}

# resouce management (probably should be moved to a dedicated service)
var resources = {
    "alcohol": 3, 
    "caviar": 2
}

var max_capacities = {
    "alcohol": 300,
    "caviar": 200    
}

var available_storage = {
    "alcohol": 297,
    "caviar": 198
}



func spawn_train(tile_pos: Vector2):
    var example_train = ["locomotive", "barracks", "cannon", "merchandise"]
    var wagon_position = grid_service.tile_to_world(tile_pos)
    #print(tile_pos, "  ", grid_service.tile_to_world(tile_pos), " ", grid_service)

    for i in range(example_train.size()):
        var wagon_type_ = example_train[i]
        var wagon_info = WagonTypes.TYPES[wagon_type_]
        var team = wagon_info.team
        if i > 0:
            wagon_position -= Vector2(wagon_info.size.x / 2, 0)
        #print("Spawning a %s at tile %s" % [wagon_type_, tile_pos])
        var id = "w%s%s" % [team[0], next_wagon_id[team]] # Player wagon with id=3 -> wP3
        next_wagon_id[team] += 1
        var wagon = wagon_info.scene.instantiate()
        
        # Dependecy injection
        #wagon.wagon_manager = self
        wagon.grid_service = grid_service

        #wagon.call_defered("initialize", id, team)
        wagon.position = wagon_position
        #wagon.current_tile = tile_pos

        wagons[team].append(wagon)
        # Add to scene tree
        get_node("../../Containers/Wagons").add_child(wagon)
        wagon_position -= Vector2(wagon_info.size.x / 2, 0)


# resouce management (probably should be moved to a dedicated service)
func add_resource_amount(resource_name_: String, qty_: int):
    if resources.has(resource_name_):
        resources[resource_name_] += qty_
    else:
        resources[resource_name_] = qty_

func remove_resource_amount(resource_name_: String, qty_: int):
    if resources.has(resource_name_):
        resources[resource_name_] -= qty_
    
func get_storage_capacity(resource_name_: String) -> int:
    if available_storage.has(resource_name_):
        return available_storage[resource_name_]
    return 0

func get_available_qty(resource_name_: String) -> int:
    if resources.has(resource_name_):
        return resources[resource_name_]
    return 0
    

