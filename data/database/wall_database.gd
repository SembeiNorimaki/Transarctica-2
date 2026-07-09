extends Node

const WALL_LEFT_SCENE = preload("res://scenes/entities/walls/wall_left.tscn")
const WALL_RIGHT_SCENE = preload("res://scenes/entities/walls/wall_right.tscn")
const WALL_FULL_SCENE = preload("res://scenes/entities/walls/wall_full.tscn")

const ATLAS_COORDS_TO_EDGE_TYPE = {
    Vector2i(0, 0): Edge.EdgeType.WALL,
    Vector2i(1, 0): Edge.EdgeType.WALL,
    Vector2i(2, 0): Edge.EdgeType.WINDOW,
    Vector2i(3, 0): Edge.EdgeType.WINDOW,
    Vector2i(3, 3): Edge.EdgeType.DOOR,
    Vector2i(4, 3): Edge.EdgeType.DOOR,
    Vector2i(5, 3): Edge.EdgeType.DOOR,
    Vector2i(6, 3): Edge.EdgeType.DOOR,
    Vector2i(2, 5): Edge.EdgeType.NORMAL,
    Vector2i(3, 5): Edge.EdgeType.NORMAL
}


func get_edge_type(atlas_coords: Vector2i) -> Edge.EdgeType:
    return ATLAS_COORDS_TO_EDGE_TYPE.get(atlas_coords)