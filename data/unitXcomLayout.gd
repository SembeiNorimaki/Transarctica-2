const FRAME_W = 32
const FRAME_H = 40

const atlas2 = {
    "torso": {
        "IdleState": {
            "N": [Vector2i(0, 2)],
            "NE": [Vector2i(1, 2)],
            "E": [Vector2i(2, 2)],
            "SE": [Vector2i(3, 2)],
            "S": [Vector2i(4, 2)],
            "SW": [Vector2i(5, 2)],
            "W": [Vector2i(6, 2)],
            "NW": [Vector2i(7, 2)]
        },
        "MoveState": {
            "N": [Vector2i(0, 2)],
            "NE": [Vector2i(1, 2)],
            "E": [Vector2i(2, 2)],
            "SE": [Vector2i(3, 2)],
            "S": [Vector2i(4, 2)],
            "SW": [Vector2i(5, 2)],
            "W": [Vector2i(6, 2)],
            "NW": [Vector2i(7, 2)]
        },
        "AimState": {
            "N": [Vector2i(0, 2)],
            "NE": [Vector2i(1, 2)],
            "E": [Vector2i(2, 2)],
            "SE": [Vector2i(3, 2)],
            "S": [Vector2i(4, 2)],
            "SW": [Vector2i(5, 2)],
            "W": [Vector2i(6, 2)],
            "NW": [Vector2i(7, 2)]
        },
    },
    "legs": {
        "IdleState": {
            "N": [Vector2i(0, 1)],
            "NE": [Vector2i(1, 1)],
            "E": [Vector2i(2, 1)],
            "SE": [Vector2i(3, 1)],
            "S": [Vector2i(4, 1)],
            "SW": [Vector2i(5, 1)],
            "W": [Vector2i(6, 1)],
            "NW": [Vector2i(7, 1)]
        },
        "AimState": {
            "N": [Vector2i(0, 1)],
            "NE": [Vector2i(1, 1)],
            "E": [Vector2i(2, 1)],
            "SE": [Vector2i(3, 1)],
            "S": [Vector2i(4, 1)],
            "SW": [Vector2i(5, 1)],
            "W": [Vector2i(6, 1)],
            "NW": [Vector2i(7, 1)]
        },
        "CrouchState": {
            "N": [Vector2i(8, 1)],
            "NE": [Vector2i(9, 1)],
            "E": [Vector2i(10, 1)],
            "SE": [Vector2i(11, 1)],
            "S": [Vector2i(12, 1)],
            "SW": [Vector2i(13, 1)],
            "W": [Vector2i(14, 1)],
            "NW": [Vector2i(15, 1)]
        },
        "MoveState": {
            "N": [Vector2i(8, 3), Vector2i(9, 3), Vector2i(10, 3), Vector2i(11, 3), Vector2i(12, 3), Vector2i(13, 3), Vector2i(14, 3), Vector2i(15, 3)],
            "NE": [Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5), Vector2i(6, 5), Vector2i(7, 5)],
            "E": [Vector2i(8, 6), Vector2i(9, 6), Vector2i(10, 6), Vector2i(11, 6), Vector2i(12, 6), Vector2i(13, 6), Vector2i(14, 6), Vector2i(15, 6)],
            "SE": [Vector2i(0, 8), Vector2i(1, 8), Vector2i(2, 8), Vector2i(3, 8), Vector2i(4, 8), Vector2i(5, 8), Vector2i(6, 8), Vector2i(7, 8)],
            "S": [Vector2i(8, 9), Vector2i(9, 9), Vector2i(10, 9), Vector2i(11, 9), Vector2i(12, 9), Vector2i(13, 9), Vector2i(14, 9), Vector2i(15, 9)],
            "SW": [Vector2i(0, 11), Vector2i(1, 11), Vector2i(2, 11), Vector2i(3, 11), Vector2i(4, 11), Vector2i(5, 11), Vector2i(6, 11), Vector2i(7, 11)],
            "W": [Vector2i(8, 12), Vector2i(9, 12), Vector2i(10, 12), Vector2i(11, 12), Vector2i(12, 12), Vector2i(13, 12), Vector2i(14, 12), Vector2i(15, 12)],
            "NW": [Vector2i(0, 14), Vector2i(1, 14), Vector2i(2, 14), Vector2i(3, 14), Vector2i(4, 14), Vector2i(5, 14), Vector2i(6, 14), Vector2i(7, 14)]
        }

    },
    "left_arm": {
        "IdleState": {
            "N": [Vector2i(0, 15)],
            "NE": [Vector2i(1, 15)],
            "E": [Vector2i(2, 15)],
            "SE": [Vector2i(3, 15)],
            "S": [Vector2i(4, 15)],
            "SW": [Vector2i(5, 15)],
            "W": [Vector2i(6, 15)],
            "NW": [Vector2i(7, 15)]
        },
        "MoveState": {
            "N": [Vector2i(0, 15)],
            "NE": [Vector2i(1, 15)],
            "E": [Vector2i(2, 15)],
            "SE": [Vector2i(3, 15)],
            "S": [Vector2i(4, 15)],
            "SW": [Vector2i(5, 15)],
            "W": [Vector2i(6, 15)],
            "NW": [Vector2i(7, 15)]
        },
        "AimState": {
            "N": [Vector2i(0, 15)],
            "NE": [Vector2i(1, 15)],
            "E": [Vector2i(2, 15)],
            "SE": [Vector2i(3, 15)],
            "S": [Vector2i(4, 15)],
            "SW": [Vector2i(5, 15)],
            "W": [Vector2i(6, 15)],
            "NW": [Vector2i(7, 15)]
        }
    },
    "right_arm": {
        "IdleState": {
            "N": [Vector2i(8, 15)],
            "NE": [Vector2i(9, 15)],
            "E": [Vector2i(10, 15)],
            "SE": [Vector2i(11, 15)],
            "S": [Vector2i(12, 15)],
            "SW": [Vector2i(13, 15)],
            "W": [Vector2i(14, 15)],
            "NW": [Vector2i(15, 15)]
        },
        "MoveState": {
            "N": [Vector2i(8, 15)],
            "NE": [Vector2i(9, 15)],
            "E": [Vector2i(10, 15)],
            "SE": [Vector2i(11, 15)],
            "S": [Vector2i(12, 15)],
            "SW": [Vector2i(13, 15)],
            "W": [Vector2i(14, 15)],
            "NW": [Vector2i(15, 15)]
        },
        "AimState": {
            "N": [Vector2i(0, 16)],
            "NE": [Vector2i(1, 16)],
            "E": [Vector2i(2, 16)],
            "SE": [Vector2i(3, 16)],
            "S": [Vector2i(4, 16)],
            "SW": [Vector2i(5, 16)],
            "W": [Vector2i(6, 16)],
            "NW": [Vector2i(7, 16)]
        }
    },
    "dead_part": {
        "DeadState": {
            "N": [Vector2i(8, 16), Vector2i(9, 16), Vector2i(10, 16)],
            "NE": [Vector2i(8, 16), Vector2i(9, 16), Vector2i(10, 16)],
            "E": [Vector2i(8, 16), Vector2i(9, 16), Vector2i(10, 16)],
            "SE": [Vector2i(8, 16), Vector2i(9, 16), Vector2i(10, 16)],
            "S": [Vector2i(8, 16), Vector2i(9, 16), Vector2i(10, 16)],
            "SW": [Vector2i(8, 16), Vector2i(9, 16), Vector2i(10, 16)],
            "W": [Vector2i(8, 16), Vector2i(9, 16), Vector2i(10, 16)],
            "NW": [Vector2i(8, 16), Vector2i(9, 16), Vector2i(10, 16)]
        }
    }
}

var atlas = {
    Vector2i(0, 2): {"ori": "N", "action": "IdleState", "part": "torso"},
    Vector2i(1, 2): {"ori": "NE", "action": "IdleState", "part": "torso"},
    Vector2i(2, 2): {"ori": "E", "action": "IdleState", "part": "torso"},
    Vector2i(3, 2): {"ori": "SE", "action": "IdleState", "part": "torso"},
    Vector2i(4, 2): {"ori": "S", "action": "IdleState", "part": "torso"},
    Vector2i(5, 2): {"ori": "SW", "action": "IdleState", "part": "torso"},
    Vector2i(6, 2): {"ori": "W", "action": "IdleState", "part": "torso"},
    Vector2i(7, 2): {"ori": "NW", "action": "IdleState", "part": "torso"},

    Vector2i(0, 1): {"ori": "N", "action": "IdleState", "part": "legs"},
    Vector2i(1, 1): {"ori": "NE", "action": "IdleState", "part": "legs"},
    Vector2i(2, 1): {"ori": "E", "action": "IdleState", "part": "legs"},
    Vector2i(3, 1): {"ori": "SE", "action": "IdleState", "part": "legs"},
    Vector2i(4, 1): {"ori": "S", "action": "IdleState", "part": "legs"},
    Vector2i(5, 1): {"ori": "SW", "action": "IdleState", "part": "legs"},
    Vector2i(6, 1): {"ori": "W", "action": "IdleState", "part": "legs"},
    Vector2i(7, 1): {"ori": "NW", "action": "IdleState", "part": "legs"},

    Vector2i(8, 1): {"ori": "N", "action": "crouch", "part": "legs"},
    Vector2i(9, 1): {"ori": "NE", "action": "crouch", "part": "legs"},
    Vector2i(10, 1): {"ori": "E", "action": "crouch", "part": "legs"},
    Vector2i(11, 1): {"ori": "SE", "action": "crouch", "part": "legs"},
    Vector2i(12, 1): {"ori": "S", "action": "crouch", "part": "legs"},
    Vector2i(13, 1): {"ori": "SW", "action": "crouch", "part": "legs"},
    Vector2i(14, 1): {"ori": "W", "action": "crouch", "part": "legs"},
    Vector2i(15, 1): {"ori": "NW", "action": "crouch", "part": "legs"},

    Vector2i(8, 3): {"ori": "N", "action": "MoveState", "part": "legs"},
    Vector2i(9, 3): {"ori": "N", "action": "MoveState", "part": "legs"},
    Vector2i(10, 3): {"ori": "N", "action": "MoveState", "part": "legs"},
    Vector2i(11, 3): {"ori": "N", "action": "MoveState", "part": "legs"},
    Vector2i(12, 3): {"ori": "N", "action": "MoveState", "part": "legs"},
    Vector2i(13, 3): {"ori": "N", "action": "MoveState", "part": "legs"},
    Vector2i(14, 3): {"ori": "N", "action": "MoveState", "part": "legs"},
    Vector2i(15, 3): {"ori": "N", "action": "MoveState", "part": "legs"},

    Vector2i(8, 6): {"ori": "E", "action": "MoveState", "part": "legs"},
    Vector2i(9, 6): {"ori": "E", "action": "MoveState", "part": "legs"},
    Vector2i(10, 6): {"ori": "E", "action": "MoveState", "part": "legs"},
    Vector2i(11, 6): {"ori": "E", "action": "MoveState", "part": "legs"},
    Vector2i(12, 6): {"ori": "E", "action": "MoveState", "part": "legs"},
    Vector2i(13, 6): {"ori": "E", "action": "MoveState", "part": "legs"},
    Vector2i(14, 6): {"ori": "E", "action": "MoveState", "part": "legs"},
    Vector2i(15, 6): {"ori": "E", "action": "MoveState", "part": "legs"},

    Vector2i(8, 9): {"ori": "S", "action": "MoveState", "part": "legs"},
    Vector2i(9, 9): {"ori": "S", "action": "MoveState", "part": "legs"},
    Vector2i(10, 9): {"ori": "S", "action": "MoveState", "part": "legs"},
    Vector2i(11, 9): {"ori": "S", "action": "MoveState", "part": "legs"},
    Vector2i(12, 9): {"ori": "S", "action": "MoveState", "part": "legs"},
    Vector2i(13, 9): {"ori": "S", "action": "MoveState", "part": "legs"},
    Vector2i(14, 9): {"ori": "S", "action": "MoveState", "part": "legs"},
    Vector2i(15, 9): {"ori": "S", "action": "MoveState", "part": "legs"},

    Vector2i(8, 12): {"ori": "W", "action": "MoveState", "part": "legs"},
    Vector2i(9, 12): {"ori": "W", "action": "MoveState", "part": "legs"},
    Vector2i(10, 12): {"ori": "W", "action": "MoveState", "part": "legs"},
    Vector2i(11, 12): {"ori": "W", "action": "MoveState", "part": "legs"},
    Vector2i(12, 12): {"ori": "W", "action": "MoveState", "part": "legs"},
    Vector2i(13, 12): {"ori": "W", "action": "MoveState", "part": "legs"},
    Vector2i(14, 12): {"ori": "W", "action": "MoveState", "part": "legs"},
    Vector2i(15, 12): {"ori": "W", "action": "MoveState", "part": "legs"},

    Vector2i(0, 5): {"ori": "NE", "action": "MoveState", "part": "legs"},
    Vector2i(1, 5): {"ori": "NE", "action": "MoveState", "part": "legs"},
    Vector2i(2, 5): {"ori": "NE", "action": "MoveState", "part": "legs"},
    Vector2i(3, 5): {"ori": "NE", "action": "MoveState", "part": "legs"},
    Vector2i(4, 5): {"ori": "NE", "action": "MoveState", "part": "legs"},
    Vector2i(5, 5): {"ori": "NE", "action": "MoveState", "part": "legs"},
    Vector2i(6, 5): {"ori": "NE", "action": "MoveState", "part": "legs"},
    Vector2i(7, 5): {"ori": "NE", "action": "MoveState", "part": "legs"},

    Vector2i(0, 8): {"ori": "SE", "action": "MoveState", "part": "legs"},
    Vector2i(1, 8): {"ori": "SE", "action": "MoveState", "part": "legs"},
    Vector2i(2, 8): {"ori": "SE", "action": "MoveState", "part": "legs"},
    Vector2i(3, 8): {"ori": "SE", "action": "MoveState", "part": "legs"},
    Vector2i(4, 8): {"ori": "SE", "action": "MoveState", "part": "legs"},
    Vector2i(5, 8): {"ori": "SE", "action": "MoveState", "part": "legs"},
    Vector2i(6, 8): {"ori": "SE", "action": "MoveState", "part": "legs"},
    Vector2i(7, 8): {"ori": "SE", "action": "MoveState", "part": "legs"},

    Vector2i(0, 11): {"ori": "SW", "action": "MoveState", "part": "legs"},
    Vector2i(1, 11): {"ori": "SW", "action": "MoveState", "part": "legs"},
    Vector2i(2, 11): {"ori": "SW", "action": "MoveState", "part": "legs"},
    Vector2i(3, 11): {"ori": "SW", "action": "MoveState", "part": "legs"},
    Vector2i(4, 11): {"ori": "SW", "action": "MoveState", "part": "legs"},
    Vector2i(5, 11): {"ori": "SW", "action": "MoveState", "part": "legs"},
    Vector2i(6, 11): {"ori": "SW", "action": "MoveState", "part": "legs"},
    Vector2i(7, 11): {"ori": "SW", "action": "MoveState", "part": "legs"},

    Vector2i(0, 14): {"ori": "NW", "action": "MoveState", "part": "legs"},
    Vector2i(1, 14): {"ori": "NW", "action": "MoveState", "part": "legs"},
    Vector2i(2, 14): {"ori": "NW", "action": "MoveState", "part": "legs"},
    Vector2i(3, 14): {"ori": "NW", "action": "MoveState", "part": "legs"},
    Vector2i(4, 14): {"ori": "NW", "action": "MoveState", "part": "legs"},
    Vector2i(5, 14): {"ori": "NW", "action": "MoveState", "part": "legs"},
    Vector2i(6, 14): {"ori": "NW", "action": "MoveState", "part": "legs"},
    Vector2i(7, 14): {"ori": "NW", "action": "MoveState", "part": "legs"},


    Vector2i(8, 15): {"ori": "N", "action": "MoveState", "part": "right_arm"},
    Vector2i(9, 15): {"ori": "NE", "action": "MoveState", "part": "right_arm"},
    Vector2i(10, 15): {"ori": "E", "action": "MoveState", "part": "right_arm"},
    Vector2i(11, 15): {"ori": "SE", "action": "MoveState", "part": "right_arm"},
    Vector2i(12, 15): {"ori": "S", "action": "MoveState", "part": "right_arm"},
    Vector2i(13, 15): {"ori": "SW", "action": "MoveState", "part": "right_arm"},
    Vector2i(14, 15): {"ori": "W", "action": "MoveState", "part": "right_arm"},
    Vector2i(15, 15): {"ori": "NW", "action": "MoveState", "part": "right_arm"},

    Vector2i(0, 15): {"ori": "N", "action": "MoveState", "part": "left_arm"},
    Vector2i(1, 15): {"ori": "NE", "action": "MoveState", "part": "left_arm"},
    Vector2i(2, 15): {"ori": "E", "action": "MoveState", "part": "left_arm"},
    Vector2i(3, 15): {"ori": "SE", "action": "MoveState", "part": "left_arm"},
    Vector2i(4, 15): {"ori": "S", "action": "MoveState", "part": "left_arm"},
    Vector2i(5, 15): {"ori": "SW", "action": "MoveState", "part": "left_arm"},
    Vector2i(6, 15): {"ori": "W", "action": "MoveState", "part": "left_arm"},
    Vector2i(7, 15): {"ori": "NW", "action": "MoveState", "part": "left_arm"},

    Vector2i(0, 16): {"ori": "N", "action": "shoot", "part": "right_arm"},
    Vector2i(1, 16): {"ori": "NE", "action": "shoot", "part": "right_arm"},
    Vector2i(2, 16): {"ori": "E", "action": "shoot", "part": "right_arm"},
    Vector2i(3, 16): {"ori": "SE", "action": "shoot", "part": "right_arm"},
    Vector2i(4, 16): {"ori": "S", "action": "shoot", "part": "right_arm"},
    Vector2i(5, 16): {"ori": "SW", "action": "shoot", "part": "right_arm"},
    Vector2i(6, 16): {"ori": "W", "action": "shoot", "part": "right_arm"},
    Vector2i(7, 16): {"ori": "NW", "action": "shoot", "part": "right_arm"},

    Vector2i(8, 16): {"ori": "SE", "action": "die", "part": "torso"},
    Vector2i(9, 16): {"ori": "SE", "action": "die", "part": "torso"},
    Vector2i(10, 16): {"ori": "SE", "action": "die", "part": "torso"}
}