extends Node

const FOOTPRINTS = {
}

const TYPES = {
    "LocomotiveWagon": {
        "horizontal_scene": preload("res://scenes/entities/wagons/locomotive_wagon.tscn"),
        "team": "Player",
        "horizontal_size": Vector2i(256, 66),
        "stores": [],
        "default_cargo": "",
        "capacity": 0
    },
    "BarracksWagon": {
        "horizontal_scene": preload("res://scenes/entities/wagons/barracks_wagon.tscn"),
        "navigation_atlas_file": "res://assets/sprites/wagons/navigation/nav_BarracksWagon.png",
        "navigation_atlas_orientations": ["SE", "S", "SW", "W", "NW", "N", "NE", "E"],
        "navigation_atlas_cargo": ["Empty_Soldiers"],
        "team": "Player",
        "horizontal_size": Vector2i(128, 48),
        "navigation_size": Vector2i(78, 55),
        "stores": ["Soldiers"],
        "default_cargo": "Soldiers",
        "capacity": 6
    },
    "CannonWagon": {
        "horizontal_scene": preload("res://scenes/entities/wagons/cannon_wagon.tscn"),
        "navigation_atlas_file": "res://assets/sprites/wagons/navigation/nav_CannonWagon.png",
        "navigation_atlas_orientations": ["SE", "S", "SW", "W", "NW", "N", "NE", "E"],
        "navigation_atlas_cargo": ["Empty_Ammunition"],
        "team": "Player",
        "horizontal_size": Vector2i(128, 58),
        "navigation_size": Vector2i(78, 55),
        "stores": ["Ammunition"],
        "default_cargo": "Ammunition",
        "capacity": 20
    },
    "MerchandiseWagon": {
        "horizontal_scene": preload("res://scenes/entities/wagons/merchandise_wagon.tscn"),
        "navigation_atlas_file": "res://assets/sprites/wagons/navigation/nav_MerchandiseWagon.png",
        "navigation_atlas_orientations": ["SE", "S", "SW", "W", "NW", "N", "NE", "E"],
        "navigation_atlas_cargo": ["Empty_Crate"],
        "team": "Player",
        "horizontal_size": Vector2i(128, 46),
        "navigation_size": Vector2i(78, 55),
        "stores": ["Crate"],
        "default_cargo": "Crate",
        "capacity": 10
    },
    "TenderWagon": {
        "horizontal_scene": preload("res://scenes/entities/wagons/tender_wagon.tscn"),
        "navigation_atlas_file": "res://assets/sprites/wagons/navigation/nav_TenderWagon.png",
        "navigation_atlas_orientations": ["SE", "S", "SW", "W", "NW", "N", "NE", "E"],
        "navigation_atlas_cargo": ["Empty_Coal"],
        "team": "Player",
        "horizontal_size": Vector2i(128, 45),
        "navigation_size": Vector2i(78, 55),
        "stores": ["Coal"],
        "default_cargo": "Coal",
        "capacity": 100
    },
    "GondolaWagon": {
        "horizontal_scene": preload("res://scenes/entities/wagons/gondola_wagon.tscn"),
        "navigation_atlas_file": "res://assets/sprites/wagons/navigation/nav_GondolaWagon.png",
        "navigation_atlas_orientations": ["SE", "S", "SW", "W", "NW", "N", "NE", "E"],
        "navigation_atlas_cargo": ["Empty_Iron", "Half_Iron", "Full_Iron", "Empty_Copper", "Half_Copper", "Full_Copper"],
        "team": "Player",
        "horizontal_size": Vector2i(178, 57),
        "navigation_size": Vector2i(78, 55),
        "stores": ["Iron", "Copper"],
        "default_cargo": "Iron",
        "capacity": 60
    },
    "OpenWagon": {
        "horizontal_scene": preload("res://scenes/entities/wagons/open_wagon.tscn"),
        "navigation_atlas_file": "res://assets/sprites/wagons/navigation/nav_OpenWagon.png",
        "navigation_atlas_orientations": ["SE", "S", "SW", "W", "NW", "N", "NE", "E"],
        "navigation_atlas_cargo": ["Empty_Wood", "Half_Wood", "Full_Wood", "Empty_IronRods", "Half_IronRods", "Full_IronRods"],
        "team": "Player",
        "horizontal_size": Vector2i(178, 57),
        "navigation_size": Vector2i(78, 55),
        "stores": ["Wood", "IronRods"],
        "default_cargo": "Wood",
        "capacity": 70
    },

    "ContainerWagon": {
        "horizontal_scene": preload("res://scenes/entities/wagons/container_wagon.tscn"),
        "navigation_atlas_file": "res://assets/sprites/wagons/navigation/nav_GondolaWagon.png",
        "navigation_atlas_orientations": ["SE", "S", "SW", "W", "NW", "N", "NE", "E"],
        "navigation_atlas_cargo": ["Empty_Container"],
        "team": "Player",
        "horizontal_size": Vector2i(299, 33),
        "stores": ["Container"],
        "default_cargo": "Container",
        "capacity": 4
    }
}


#func get_unit_type_from_atlas_coords(source_id: int, coords: Vector2i) -> String:
#    return atlas_map[source_id][coords]

#func get_owner_id_from_atlas_coords(coords: Vector2i) -> String:
#    return atlas_x_to_team[coords.x]
