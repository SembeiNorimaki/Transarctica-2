extends Node
class_name UnitAI

@onready var owner_node = get_parent()

func _ready():
	pass

func decide_action():
	print("Deciding action for unit %s" % owner_node.id)
