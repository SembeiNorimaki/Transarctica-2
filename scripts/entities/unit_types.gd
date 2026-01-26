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
	"artillery": {
		"scene": preload("res://scenes/entities/units/artillery.tscn"),
		"footprint": "2x2",
		"team": "Player"
	},
	"tank": {
		"scene": preload("res://scenes/entities/units/tank.tscn"),
		"footprint": "2x2",
		"team": "Player"
	},
	"ghost": {
		"scene": preload("res://scenes/entities/units/ghost2.tscn"),
		"footprint": "1x1",
		"team": "Player"
	},
	"unit_xcom": {
		"scene": preload("res://scenes/entities/units/unit_xcom2.tscn"),
		"footprint": "1x1",
		"team": "Player"
	}
}

var atlas_map = {
	0: {
		Vector2i(0, 0): "artillery",
		Vector2i(0, 1): "tank"
	},
	1: {
		Vector2i(0, 0): "ghost",
		Vector2i(0, 1): "unit_xcom",
		Vector2i(1, 0): "ghost",
		Vector2i(1, 1): "unit_xcom",

	}

}

var atlas_x_to_team = {
	0: "Player",
	1: "Enemy"
}

# var atlas_to_owner_id = {
# 	Vector2i(0, 0): "Player",
# 	Vector2i(0, 1): "Player",
# 	Vector2i(0, 2): "Player",
# 	Vector2i(0, 3): "Player",
# 	Vector2i(0, 4): "Player",
# 	Vector2i(0, 5): "Player",
# 	Vector2i(0, 6): "Player",
	
# 	Vector2i(0, 7): "Enemy",
# 	Vector2i(0, 8): "Enemy",
# 	Vector2i(0, 9): "Enemy",
# 	Vector2i(0, 10): "Enemy",
# 	Vector2i(0, 11): "Enemy",
# 	Vector2i(0, 12): "Enemy",
# 	Vector2i(0, 13): "Enemy"
# }

func get_unit_type_from_atlas_coords(source_id: int, coords: Vector2i) -> String:
	return atlas_map[source_id][coords]

func get_owner_id_from_atlas_coords(coords: Vector2i) -> String:
	return atlas_x_to_team[coords.x]
