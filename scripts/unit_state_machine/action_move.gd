extends Node

var parent_scene: Node = null
var target_tile = Vector2i(-1, -1)

func enter(prev):
    print("Entered unit move state")

func exit(next):
    print("Exiting unit move state")

func handle_click(tile: Vector2i, button_index: int):
    pass