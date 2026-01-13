extends Node

const TYPES = {
    "barracks": {
        "scene": preload("res://scenes/entities/buildings/barracks.tscn"),
        "footprint": Vector2i(4, 4)
    },
    "power_plant": {
        "scene": preload("res://scenes/entities/buildings/power_plant.tscn"),
        "footprint": Vector2i(1, 1)
    }
}

const FOOTPRINTS = {
    Vector2i(1, 1): [
        Vector2i(0, 0),
    ],
    Vector2i(4, 4): [
        Vector2i(-1, -1),
        Vector2i(0, -1),
        Vector2i(1, -1),
        Vector2i(2, -1),

        Vector2i(-1, 0),
        Vector2i(0, 0),
        Vector2i(1, 0),
        Vector2i(2, 0),

        Vector2i(-1, 1),
        Vector2i(0, 1),
        Vector2i(1, 1),
        Vector2i(2, 1),

        Vector2i(-1, 2),
        Vector2i(0, 2),
        Vector2i(1, 2),
        Vector2i(2, 2)
    ]
}

var atlas_map = {
    Vector2i(1, 0): "barracks",
    Vector2i(2, 0): "power_plant"
}

func get_building_type_from_atlas_coords(coords: Vector2i) -> String:
    return atlas_map[coords]

func get_footprint(building_type: String) -> Array:
    return FOOTPRINTS[TYPES[building_type]["footprint"]]
