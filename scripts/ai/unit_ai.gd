extends Node
class_name UnitAI

@onready var owner_node = get_parent()

signal turn_done

func _ready():
	pass

# This is annoyingly needed because state machine requires it. Should be changed
func update_state_label(name: String):
	pass

func take_turn() -> Signal:
	_run_behavior()
	return turn_done

func _run_behavior() -> void:
	print("Running unitAI...")
	# Example behavior
	#if unit.can_see_player():
	#	await unit.shoot_player()
	#else:
	#	await unit.move_towards_last_known_position()
	
	#turn_done.emit()
