extends Node
class_name GenericState

var owner_node: Node
var state_machine: StateMachine

func set_owner_node(owner: Node) -> void:
    owner_node = owner

func set_state_machine(sm: StateMachine) -> void:
    state_machine = sm

func enter(prev, params = {}):
    pass

func exit(next, params = {}):
    pass

func update(delta: float):
    pass