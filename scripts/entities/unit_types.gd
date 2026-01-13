extends Node


const TYPES = {
    "artillery": {
        "scene": preload("res://scenes/entities/units/artillery.tscn")
    },
    "tank": {
        "scene": preload("res://scenes/entities/units/tank.tscn")
    },
    "ghost": {
        "scene": preload("res://scenes/entities/units/ghost2.tscn")
    },
    "unit_xcom": {
        "scene": preload("res://scenes/entities/units/unit_xcom2.tscn")
    }
}

var atlas_map = {
    Vector2i(0, 0): "artillery",
    Vector2i(0, 1): "tank",
    Vector2i(0, 2): "ghost",
    Vector2i(0, 3): "unit_xcom"
}

func get_unit_type_from_atlas_coords(coords: Vector2i) -> String:
    return atlas_map[coords]
