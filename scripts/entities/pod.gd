extends Node2D
class_name Pod

var grid_service: GridService
var pod_manager: PodManager

var current_tile := Vector2i(-1, -1)
var patrol_route: Array[Vector2i] = []