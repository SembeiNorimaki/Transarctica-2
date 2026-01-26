extends Node2D
class_name Unit

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var sprite_selected = $SpriteSelected
@onready var action_sm = $ActionStateMachine

@onready var weapon_service: WeaponService

#Labels
@onready var id_label = $Labels/IDLabel
@onready var state_label = $Labels/StateLabel

var grid_service: GridService
var unit_manager: UnitManager

var current_tile = Vector2i(-1, -1)
var target_tile = Vector2i(-1, -1)

var id: String = ""
var team_id: String = ""
var move_speed := 80.0
var orientation := "SE"
var view_angle := 90.0
var view_range := 12

signal movement_finished


func _ready() -> void:
	pass
	#set_process(false)

func initialize(id_: String, team_id_: String) -> void:
	id = id_
	id_label.text = id
	set_team(team_id_)

func set_id(id_: String) -> void:
	if id == "":
		id = id_
	else:
		push_error("Unit already has an id")

func set_team(team_id_: String):
	team_id = team_id_
	if team_id == "enemy":
		sprite.modulate = Color.RED
	

#func _process(delta: float) -> void:
	#action_sm.update(delta)
	#var target_pos = grid_service.tile_to_world(target_tile)
	#global_position = global_position.move_toward(target_pos, move_speed * delta)
	#if global_position.distance_to(target_pos) < 0.1:
	#    global_position = target_pos
	#    #set_process(false)
	#    unit_manager.on_unit_reached_tile(self)


func set_state(state: String, params = {}) -> void:
	action_sm.set_state(state, params)
	update_state_label(state)

func set_orientation(new_orientation: String):
	orientation = new_orientation
	sprite.set_animation(new_orientation)
	unit_manager.on_unit_orientation_changed(self, new_orientation)
	queue_redraw()
	
	
func _draw():
	print("Grid service %s for unit %s %s" % [grid_service, id, self])
	#var dst_tile = grid_service.ORIENTATION_VECTORS[orientation] * 4
	#var pos = grid_service.tile_delta_to_world_delta(dst_tile)
	#draw_line(Vector2.ZERO, pos, Color.BLUE, 2)
	#queue_redraw()

func update_state_label(state_name: String):
	state_label.text = name

func play_animation(name):
	sprite.play(name)

func stop_animation():
	sprite.stop()

func set_selected(selected: bool) -> void:
	#print("Selected: %s" % selected)
	sprite_selected.visible = selected


func move_to_tile(tile: Vector2i):
	#print("Unit %s instructed to move to tile %s" % [id, tile])
	target_tile = tile
	set_state("MoveState", {"unit": self})
	#set_process(true)

func on_arrived_to_tile(tile: Vector2i):
	unit_manager.on_unit_reached_tile(self, tile)

func on_movement_finished() -> void:
	#set_process(false)
	emit_signal("movement_finished")
