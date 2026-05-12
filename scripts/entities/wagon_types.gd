extends Node

const FOOTPRINTS = {
}

const TYPES = {
	"LocomotiveWagon": {
		"scene": preload("res://scenes/entities/wagons/locomotive_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(256, 66)
	},
	"BarracksWagon": {
		"scene": preload("res://scenes/entities/wagons/barracks_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(128, 48)
	},
	"CannonWagon": {
		"scene": preload("res://scenes/entities/wagons/cannon_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(128, 58)
	},
	"MerchandiseWagon": {
		"scene": preload("res://scenes/entities/wagons/merchandise_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(128, 46)
	},
	"TenderWagon": {
		"scene": preload("res://scenes/entities/wagons/tender_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(128, 45)
	},
	"GondolaWagon": {
		"scene": preload("res://scenes/entities/wagons/gondola_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(178, 57)
	},
	"ContainerWagon": {
		"scene": preload("res://scenes/entities/wagons/container_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(299, 33)
	}
}


#func get_unit_type_from_atlas_coords(source_id: int, coords: Vector2i) -> String:
#	return atlas_map[source_id][coords]

#func get_owner_id_from_atlas_coords(coords: Vector2i) -> String:
#	return atlas_x_to_team[coords.x]
