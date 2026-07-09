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
    ],
    "3x3": [
        Vector2i(-1, -1),
        Vector2i(-1, 0),
        Vector2i(-1, 1),
        Vector2i(0, -1),
        Vector2i(0, 0),
        Vector2i(0, 1),
        Vector2i(1, -1),
        Vector2i(1, 0),
        Vector2i(1, 1)
    ],
    "1x2": [
        Vector2i(0, 0),
        Vector2i(0, 1)
    ],
    "2x1": [
        Vector2i(0, 0),
        Vector2i(1, 0)
    ]
}

func get_footprint(footprint_type: String) -> Array:
    return FOOTPRINTS.get(footprint_type, [])
