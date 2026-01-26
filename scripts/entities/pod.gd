extends Node2D
class_name Pod

var grid_service: GridService
var pod_manager: PodManager

var current_tile := Vector2i(-1, -1)
var target_tile := Vector2i(-1, -1)
var patrol_route: Array[Vector2i] = []
var units: Array[Unit] = []
var id: String

@onready var id_label: Label = $Labels/IDLabel
@onready var state_label: Label = $Labels/StateLabel
@onready var action_sm = $PodStateMachine

signal movement_finished
signal turn_finished


func take_turn():
	print("Pod %s taking turn" % id)
	emit_signal("turn_finished")
	
func set_state(state: String, params = {}) -> void:
	action_sm.set_state(state, params)
	state_label.text = state

func move_to_tile(tile: Vector2i):
	print("Pod %s instructed to move to tile %s" % [id, tile])
	target_tile = tile
	set_state("MoveState", {"pod": self})

func update_state_label(state_name: String):
	state_label.text = "State: %s" % state_name

func on_arrived_to_tile(tile: Vector2i):
	pod_manager.on_pod_reached_tile(self, tile)

func on_movement_finished() -> void:
	emit_signal("movement_finished")
