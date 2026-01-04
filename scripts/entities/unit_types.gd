extends Node


const TYPES = {
    "artillery": {
        "scene": preload("res://scenes/entities/units/artillery.tscn")
    },
    "tank": {
        "scene": preload("res://scenes/entities/units/tank.tscn")
    }
}

var atlas_map = {
    Vector2i(0, 0): "artillery",
    Vector2i(0, 1): "tank"
}

func get_unit_type_from_atlas_coords(coords: Vector2i) -> String:
    return atlas_map[coords]
