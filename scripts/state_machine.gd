extends Node
class_name StateMachine

var owner_node: Node = null
var current_state: Node = null
var states: Dictionary = {} # Key: state name, Value: state instance eg: {"IdleState": IdleState}
var id: String

#signal state_finished

func _ready():
	owner_node = get_parent()
	id = owner_node.name
	# print("Initializing state machine %s" % id)
	# Discover all child states automatically
	for child in get_children():
		if child is GenericState:
			# print("Child state found: %s" % child.name)
			states[child.name] = child
			child.set_owner_node(owner_node)
			child.set_state_machine(self)
		##print("SM %s Discovered child %s of type %s" % [id, child.name, child])
	call_deferred("init")

func init() -> void:
    # Initialize to IdleState or first state
    if states.has("IdleState"):
        set_state("IdleState")
    else:
        set_state(states.keys()[0])


func _process(delta: float) -> void:
    current_state.update(delta)
    
func set_state(new_state_str: String, params = {}) -> void:
    #print("Setting state to %s" % new_state_str)
    #print("Available states: %s" % states)
    var new_state = states[new_state_str]
    
    if current_state:
        current_state.exit({})
    var _prev_state = current_state
    current_state = new_state
    owner_node.update_state_label(new_state.name)
    #print("New state %s " % new_state.name, prev_state)
    new_state.enter(params)

func get_current_state() -> String:
    return current_state.name

func handle_click(tile: Vector2i) -> void:
    current_state.handle_click(tile)
