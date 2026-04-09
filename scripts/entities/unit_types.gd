extends Node

const FOOTPRINTS = {
	"1x1": [
		Vector2i(0, 0)
	],
	"2x2": [
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(1, 0),
		Vector2i(1, 1)
	]
}

const TYPES = {
	"unit_xcom": {
		"scene": preload("res://scenes/entities/units/unit_xcom2.tscn"),
		"footprint": "1x1",
	}
}


var atlas_y_to_team = {
	0: "Player",
	1: "Enemy"
}

var atlas_x_to_type = {
	0: "elite_soldier",
	1: "liquidator",
	2: "pioneer",
	3: "redops",
	4: "swat",
	5: "mercenary"
}

func get_unit_type_from_atlas_coords(coords: Vector2i) -> String:
	return atlas_x_to_type[coords.x]

func get_owner_id_from_atlas_coords(coords: Vector2i) -> String:
	return atlas_y_to_team[coords.y]
