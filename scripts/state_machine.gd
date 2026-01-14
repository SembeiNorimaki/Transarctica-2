extends Node
class_name StateMachine

var parent_scene = null
var current_state: Node = null
var states: Dictionary = {}
var id: String

func _ready():
	parent_scene = get_parent()
	id = parent_scene.name
	print("State machine %s ready" % id)
	# Discover all child states automatically
	for child in get_children():
		print("Discovered child state %s with parent %s" % [child.name, parent_scene])
		states[child.name] = child
		child.parent_scene = parent_scene
	call_deferred("init")

func init() -> void:
	# Initialize to IdleState
	if states.has("IdleState"):
		set_state("IdleState")
	else:
		push_error("IdleState not found in CombatInputStateMachine children")


func _process(delta: float) -> void:
	current_state.update(delta)
	
func set_state(new_state_str: String, params = {}) -> void:
	var new_state = states[new_state_str]
	print("SM %s Setting state to %s with params %s" % [id, new_state.name, params])
	if current_state:
		current_state.exit(new_state)
	var prev_state = current_state
	current_state = new_state
	parent_scene.update_state_label(new_state.name)
	new_state.enter(prev_state, params)

func handle_click(tile: Vector2i) -> void:
	current_state.handle_click(tile)
