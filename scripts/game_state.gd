extends Node

var state := {
    "cities": {},
    "industries": {},
    "train": {}
}

var cities_by_location = {}

func _ready() -> void:
    print("Game state Ready")
    load_initial_cities()

func load_initial_cities():
    var file = FileAccess.open("res://scripts/data/cities.json", FileAccess.READ)
    var cities_data = JSON.parse_string(file.get_as_text())
    for city_name in cities_data.keys():
        var city_location_array = cities_data[city_name]["Location"]
        cities_by_location[str(city_location_array[0]) + "," + str(city_location_array[1])] = city_name
    print("cities_by_location: ", cities_by_location)
    state["cities"] = cities_data
    print("state:", state)


func get_city(name: String) -> Dictionary:
    return state["cities"].get(name, {})

func add_goods_to_city(city_name: String, good_name: String, amount: int):
    state["cities"][city_name]["goods"][good_name] += amount

func save():
    var json = JSON.stringify(state)
    FileAccess.open("user://save,json", FileAccess.WRITE).store_string(json)

func load():
    var file = FileAccess.open("user://save.json", FileAccess.READ)
    if file:
        state = JSON.parse_string(file.get_as_text())
