const FRAME_W = 32
const FRAME_H = 40

const aux = {
    "WeaponIdle": {
        "W": [Vector2i(6, 0)],
        "NW": [Vector2i(7, 0)],
        "N": [Vector2i(0, 0)],
        "NE": [Vector2i(1, 0)],
        "E": [Vector2i(2, 0)],
        "SE": [Vector2i(3, 0)],
        "S": [Vector2i(4, 0)],
        "SW": [Vector2i(5, 0)]
    },
    "WeaponAim": {
        "W": [Vector2i(0, 0)],
        "NW": [Vector2i(1, 0)],
        "N": [Vector2i(2, 0)],
        "NE": [Vector2i(3, 0)],
        "E": [Vector2i(4, 0)],
        "SE": [Vector2i(5, 0)],
        "S": [Vector2i(6, 0)],
        "SW": [Vector2i(7, 0)]
    }
}

const atlas = {
    "weapon": {
        "IdleState": aux.WeaponIdle,
        "MoveState": aux.WeaponIdle,
        "AimState": aux.WeaponAim
    }
}
