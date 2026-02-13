extends Node2D
class_name Unit

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var sprite_selected = $SpriteSelected
@onready var action_sm = $ActionStateMachine
@onready var weapon_service: WeaponService
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: HealthBar = $HealthBar

#Labels
@onready var id_label = $Labels/IDLabel
@onready var state_label = $Labels/ActionStateLabel

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
	health_component.connect("health_changed", _on_health_changed)
	health_component.connect("died", _on_died)

	#Initialize bar
	health_bar.update_health(health_component.current_health, health_component.max_health)
	#set_process(false)

func initialize(id_: String, team_id_: String) -> void:
	set_id(id_)
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


func set_soldier_type(id: String):
	pass
	
func get_current_action():
	return action_sm.current_state.name


func _on_health_changed(current: int, max: int):
	#print("Unit _on_health_changed %s %s" % [current, max])
	health_bar.visible = current < max # hide health bar when at full health
	health_bar.update_health(current, max)

func _on_died():
	health_bar.visible = false


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
	#print("Unit: Setting orientation to %s" % new_orientation)
	orientation = new_orientation
	sprite.set_animation(new_orientation)
	unit_manager.on_unit_orientation_changed(self, new_orientation)
	queue_redraw()
	
	
func _draw():
	pass
	#print("Grid service %s for unit %s %s" % [grid_service, id, self])
	#var dst_tile = grid_service.ORIENTATION_VECTORS[orientation] * 4
	#var pos = grid_service.tile_delta_to_world_delta(dst_tile)
	#draw_line(Vector2.ZERO, pos, Color.BLUE, 2)
	#queue_redraw()
func update_state_label(state_name: String):
	state_label.text = name

# func play_animation(name):
# 	sprite.play(name)

func stop_animation():
	sprite.stop()

func set_selected(selected: bool) -> void:
	#print("Selected: %s" % selected)
	sprite_selected.visible = selected


func move_to_tile(tile: Vector2i):
	#print("Unit %s instructed to move to tile %s" % [id, tile])
	target_tile = tile
	# calculate new orientation
	var delta = target_tile - current_tile
	var new_ori = grid_service.get_orientation(current_tile, target_tile)
	set_orientation(new_ori)
	#set_state("MoveState", {"unit": self})
	#
	#set_process(true)

func on_arrived_to_tile(tile: Vector2i):
	unit_manager.on_unit_reached_tile(self, tile)

func on_movement_finished() -> void:
	#set_process(false)
	emit_signal("movement_finished")
