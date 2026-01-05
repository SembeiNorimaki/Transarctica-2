extends Node
class_name StateMachine

var parent_scene: Node2D
var current_state: Node = null
var states: Dictionary = {}

func _ready():
	print("Combat State Machine ready")
	parent_scene = get_parent()
	# Discover all child states automatically
	for child in get_children():
		states[child.name] = child
		child.parent_scene = parent_scene

	call_deferred("init")
	

func init() -> void:
	# Initialize to IdleState
	if states.has("IdleState"):
		set_state(states["IdleState"])
	else:
		push_error("IdleState not found in CombatInputStateMachine children")

func set_state(new_state: Node) -> void:
	print("Setting state to %s" % new_state.name)
	if current_state:
		current_state.exit(new_state)
	var prev_state = current_state
	current_state = new_state
	parent_scene.update_state_label(new_state.name)
	new_state.enter(prev_state)

func handle_click(tile: Vector2i) -> void:
	current_state.handle_click(tile)
