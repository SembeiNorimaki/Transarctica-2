extends Node

var state := {
	"cities": {},
	"industries": {},
	"train": {}
}

var cities_by_location = {}
var cities_by_id = {}
var industries_by_location = {}

func _ready() -> void:
	print("Game state Ready")
	load_initial_cities()
	load_initial_train()
	print("cities_by_location: ", cities_by_location)
	print("state:", state)

func load_initial_cities():
	var file = FileAccess.open("res://scripts/data/cities.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	for city_id in data.keys():
		var city_name = data[city_id].Name
		var city_location = Vector2i(data[city_id].Location[0], data[city_id].Location[1])
		cities_by_location[city_location] = city_name
		cities_by_id[int(city_id)] = city_name
		state.cities[city_name] = data[city_id]

func load_initial_industries():
	var file = FileAccess.open("res://scripts/data/industries.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	for industry_name in data.keys():
		var location_array = data[industry_name]["Location"]
		var industry_tile = Vector2i(location_array[0], location_array[1])
		industries_by_location[industry_tile] = industry_name
	state["industries"] = data


func load_initial_train():
	var file = FileAccess.open("res://scripts/data/player_train.json", FileAccess.READ)
	var train_data = JSON.parse_string(file.get_as_text())
	state.train.wagons = []
	for wagon_info in train_data.wagons:
		state.train.wagons.append(wagon_info)
		#print("Initial wagon %s" % wagon_name)


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
