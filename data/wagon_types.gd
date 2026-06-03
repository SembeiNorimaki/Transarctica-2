extends Node

const FOOTPRINTS = {
}

const TYPES = {
	"LocomotiveWagon": {
		"scene": preload("res://scenes/entities/wagons/locomotive_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(256, 66),
		"stores": []
	},
	"BarracksWagon": {
		"scene": preload("res://scenes/entities/wagons/barracks_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(128, 48),
		"stores": ["soldiers"]
	},
	"CannonWagon": {
		"scene": preload("res://scenes/entities/wagons/cannon_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(128, 58),
		"stores": ["ammunition"]
	},
	"MerchandiseWagon": {
		"scene": preload("res://scenes/entities/wagons/merchandise_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(128, 46),
		"stores": ["crate"]
	},
	"TenderWagon": {
		"scene": preload("res://scenes/entities/wagons/tender_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(128, 45),
		"stores": ["coal"]
	},
	"GondolaWagon": {
		"trade_scene": preload("res://scenes/entities/wagons/gondola_wagon.tscn"),
		"navigation_atlas_file": "res://assets/sprites/wagons/navigation/nav_GondolaWagon.png"
		"navigation_atlas_orientations": ["SE", "S", "SW", "W", "NW", "N", "NE", "E"],
		"navigation_atlas_cargo": ["Empty", "Half_Iron", "Full_Iron", "Half_Copper", "Full_Copper"],
		"team": "Player",
		"horizontal_size": Vector2i(178, 57),
		"navigation_size": Vector2i(78, 55),
		"stores": ["iron", "copper"]
	},
	"OpenWagon": {
		"trade_scene": preload("res://scenes/entities/wagons/open_wagon.tscn"),
		"team": "Player",
		"horizontal_size": Vector2i(178, 57),
		"stores": []
	},

	"ContainerWagon": {
		"scene": preload("res://scenes/entities/wagons/container_wagon.tscn"),
		"team": "Player",
		"size": Vector2i(299, 33),
		"stores": ["container"]
	}
}


#func get_unit_type_from_atlas_coords(source_id: int, coords: Vector2i) -> String:
#	return atlas_map[source_id][coords]

#func get_owner_id_from_atlas_coords(coords: Vector2i) -> String:
#	return atlas_x_to_team[coords.x]
