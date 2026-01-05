extends Node

var parent_scene: Node = null

func enter(prev):
	print("Entered idle state")

func exit(next):
	print("Exiting idle state")

func handle_click(tile: Vector2i, button_index: int):
	pass
