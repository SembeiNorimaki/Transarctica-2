extends Node

const FOOTPRINTS = {
}

const TYPES = {
	"locomotive": {
		"scene": preload("res://scenes/entities/wagons/locomotive_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(256, 66)
	},
	"barracks": {
		"scene": preload("res://scenes/entities/wagons/barracks_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(128, 48)
	},
	"cannon": {
		"scene": preload("res://scenes/entities/wagons/cannon_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(128, 58)
	},
	"merchandise": {
		"scene": preload("res://scenes/entities/wagons/merchandise_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(128, 46)
	}
}


#func get_unit_type_from_atlas_coords(source_id: int, coords: Vector2i) -> String:
#	return atlas_map[source_id][coords]

#func get_owner_id_from_atlas_coords(coords: Vector2i) -> String:
#	return atlas_x_to_team[coords.x]
