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
    Vector2i(0, 3): "unit_xcom",

    Vector2i(0, 8): "artillery",
    Vector2i(0, 9): "tank",
    Vector2i(0, 10): "ghost",
    Vector2i(0, 11): "unit_xcom"

}

var atlas_to_owner_id = {
    Vector2i(0, 0): "player",
    Vector2i(0, 1): "player",
    Vector2i(0, 2): "player",
    Vector2i(0, 3): "player",
    Vector2i(0, 4): "player",
    Vector2i(0, 5): "player",
    Vector2i(0, 6): "player",
    Vector2i(0, 7): "player",

    Vector2i(0, 8): "enemy",
    Vector2i(0, 9): "enemy",
    Vector2i(0, 10): "enemy",
    Vector2i(0, 11): "enemy",
    Vector2i(0, 12): "enemy",
    Vector2i(0, 13): "enemy",
    Vector2i(0, 14): "enemy",
    Vector2i(0, 15): "enemy",

}

func get_unit_type_from_atlas_coords(coords: Vector2i) -> String:
    return atlas_map[coords]

func get_owner_id_from_atlas_coords(coords: Vector2i) -> int:
    return coords.y
