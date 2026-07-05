extends Node

var state := {
    "cities": {},
    "industries": {},
    "train": {},
    "money": 1000,
    "fuel": 100,
    "quests": {
        "active": {},
        "completed": []
    }
}

# this are examples for showing the structure of the data. They are removed when loading data from JSON files
var _cities_state = {
    "ËxampleCity": {
        "TradeResources": {
            "Oil": {
                "Quantity": 3,
                "SellPrice": 4,
                "BuyPrice": 5
            },
            "Alcohol": {
                "Quantity": 6,
                "SellPrice": 7,
                "BuyPrice": 8
            }
        }
    }
}

var _industries_state = {
    "ËxampleIndustry": {
        "Requires": ["wood", "iron"],
        "Produces": ["rails"],
        "formula": {
            "input": {
                "wood": 3,
                "iron": 2
            },
            "output": {
                "rails": 1
            }
        }
    }
}

var _player_train_state = {
    "id": "TP0",
    "owner": "Player",
    "position": [2, 4, "E"],
    
    "fuel": 40,
    "max_fuel": 100,
    "max_speed": 100,
    "acceleration": 10,
    "deceleration": 20,

    "wagons": [
        {
            "type": "locomotive",
            "hp": 100,
            "max_hp": 100,
            "capacity": 0,
            "cargo_name": "",
            "cargo_qty": 0
        },
        {
            "type": "tender",
            "hp": 60,
            "max_hp": 60,
            "capacity": 100,
            "cargo_name": "coal",
            "cargo_qty": 40
        },
        {
            "type": "merchandise",
            "hp": 40,
            "max_hp": 40,
            "capacity": 20,
            "cargo_name": "caviar",
            "cargo_qty": 3
        }
    ]
}


# cities_state stores cities by name. To retrieve cities by location or id, this dictionaries provide a correspondence loc->name and id->name
# in any case, to get cities data, use the API calls get_city_by_name, get_city_by_location, get_city_by_id
var _cities_by_location = {}
var _cities_by_id = {}
var _industries_by_location = {}
var _industries_by_id = {}
var _units_state: Dictionary = {}

#region initialization
func _ready() -> void:
    # print("Game state Ready")
    load_initial_cities("cities_World2.json")
    #load_initial_industries("industries.json")
    load_initial_units("units.json")
    load_initial_player_train("player_train.json")
    
    
    # print(_cities_state.keys())

func load_initial_cities(filename: String):
    _cities_state = {}
    _cities_by_location = {}
    _cities_by_id = {}

    var file = FileAccess.open("res://data/%s" % filename, FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    for city_id in data.keys():
        var city_name = data[city_id].Name
        var city_location = Vector2i(data[city_id].Location[0], data[city_id].Location[1])
        _cities_by_location[city_location] = city_name
        _cities_by_id[int(city_id)] = city_name
        _cities_state[city_name] = data[city_id]

func load_initial_industries(filename: String):
    _industries_state = {}
    _industries_by_location = {}
    _industries_by_id = {}

    var file = FileAccess.open("res://data/%s" % filename, FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    for industry_id in data.keys():
        var industry_name = data[industry_id].Name
        var industry_location = Vector2i(data[industry_id].Location[0], data[industry_id].Location[1])

        _industries_by_location[industry_location] = industry_name
        _industries_by_id[industry_id] = industry_name
        _industries_state[industry_name] = data[industry_id]
        
    state["industries"] = data

func load_initial_player_train(filename: String):
    _player_train_state = {}

    var file = FileAccess.open("res://data/%s" % filename, FileAccess.READ)
    var train_data = JSON.parse_string(file.get_as_text())
    _player_train_state = train_data

func load_initial_units(filename: String) -> void:
    _units_state = {}
    var file = FileAccess.open("res://data/%s" % filename, FileAccess.READ)
    if file == null:
        push_error("GameState: could not open %s" % filename)
        return
    var data = JSON.parse_string(file.get_as_text())
    _units_state = data

#endregion

#region publicAPI

# Money
func get_money() -> int:
    return state.money

func add_money(amount: int) -> void:
    state.money += amount

func subtract_money(amount: int) -> void:
    state.money -= amount


# Player Train State
func get_player_train() -> Dictionary:
    return _player_train_state

func set_player_train(player_train_data: Dictionary) -> void:
    _player_train_state = player_train_data

func set_wagon_cargo(wagon_idx: int, resource_name: String, qty: int) -> void:
    pass
func get_wagon_cargo(wagon_idx: int) -> Dictionary:
    return {}


# City State
func get_all_city_names() -> Array:
    return _cities_state.keys()
    
func get_city_by_name(city_name: String) -> Dictionary:
    return _cities_state.get(city_name, {})

func get_city_by_location(loc: Vector2i) -> Dictionary:
    return _cities_state.get(_cities_by_location[loc], {})

func get_city_by_id(id: int) -> Dictionary:
    return _cities_state.get(_cities_by_id[id], {})

func set_city(city_name: String, city_data: Dictionary) -> void:
    _cities_state[city_name] = city_data

# Industry State
func get_all_industry_names() -> Array:
    return _industries_state.keys()

func get_industry_by_name(industry_name: String) -> Dictionary:
    return _industries_state.get(industry_name, {})

func get_industry_by_location(location: Vector2i) -> Dictionary:
    return _industries_state.get(_industries_by_location[location], {})

func get_industry_by_id(id: String) -> Dictionary:
    return _industries_state.get(_industries_by_id[id], {})

func set_industry(industry_name: String, industry_data: Dictionary) -> void:
    _industries_state[industry_name] = industry_data


# Units
func get_unit(id: String) -> Dictionary:
    return _units_state.get(id, {})

func get_all_units() -> Dictionary:
    return _units_state

func add_unit(data: Dictionary) -> String:
    # Auto-generate a sequential ID
    var idx := _units_state.size()
    var id := "s%d" % idx
    while _units_state.has(id): # avoid collision if there are gaps
        idx += 1
        id = "s%d" % idx
    data["id"] = id
    _units_state[id] = data
    return id

func update_unit(id: String, data: Dictionary) -> void:
    if _units_state.has(id):
        _units_state[id].merge(data, true) # true = overwrite existing keys
    else:
        push_error("GameState.update_unit: unknown unit id '%s'" % id)

func remove_unit(id: String) -> void:
    _units_state.erase(id)

# Convenience: resolve unit_ids for a specific barracks wagon index
func get_units_in_barracks(wagon_idx: int) -> Array[Dictionary]:
    var wagon = _player_train_state.wagons[wagon_idx]
    var result: Array[Dictionary] = []
    for uid in wagon.get("unit_ids", []):
        var unit_data = get_unit(uid)
        if not unit_data.is_empty():
            result.append(unit_data)
    return result

# Remove a unit ID from its barracks wagon (call on permadeath alongside remove_unit)
func remove_unit_from_barracks(unit_id: String) -> void:
    for wagon in _player_train_state.wagons:
        if wagon.get("type") == "BarracksWagon":
            wagon.get("unit_ids", []).erase(unit_id)

#endregion


func save_player_train(filename: String = "user://PlayerTrain_Save.json") -> void:
    var json_text := JSON.stringify(state, "\t") # pretty print with tabs

    var file := FileAccess.open(filename, FileAccess.WRITE)
    if file == null:
        push_error("Could not write %s" % filename)
        return

    file.store_string(json_text)
    

func add_goods_to_city(city_name: String, resource_name: String, qty: int):
    _cities_state[city_name].TradeResources[resource_name].Quantity += qty

func remove_goods_from_city(city_name: String, resource_name: String, qty: int):
    _cities_state[city_name].TradeResources[resource_name].Quantity -= qty


func update_wagon_cargo(wagon_idx: int, resource_name: String, qty: int):
    if resource_name == "":
        _player_train_state.wagons[wagon_idx].cargo_name = ""
        _player_train_state.wagons[wagon_idx].cargo_qty = 0
    else:
        _player_train_state.wagons[wagon_idx].cargo_name = resource_name
        _player_train_state.wagons[wagon_idx].cargo_qty = qty

func save():
    var json = JSON.stringify(state)
    FileAccess.open("user://save.json", FileAccess.WRITE).store_string(json)

func load():
    var file = FileAccess.open("user://save.json", FileAccess.READ)
    if file:
        state = JSON.parse_string(file.get_as_text())
