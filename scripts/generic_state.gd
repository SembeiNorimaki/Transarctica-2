extends Node
class_name GenericState

var owner_node: Node
var state_machine: StateMachine

func set_owner_node(owner: Node) -> void:
	owner_node = owner

func set_state_machine(sm: StateMachine) -> void:
	state_machine = sm

func enter(_params = {}):
	#print("Generic enter")
	pass

func exit(_params = {}):
	pass

func update(_delta: float):
	pass
