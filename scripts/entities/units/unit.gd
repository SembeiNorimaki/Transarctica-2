extends Node2D
class_name Unit

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var sprite_selected = $SpriteSelected
@onready var action_sm = $ActionStateMachine
@onready var weapon_service: WeaponService
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: HealthBar = $HealthBar
@onready var ap_component: ApComponent = $ApComponent

#Labels
@onready var id_label = $Labels/IDLabel
@onready var state_label = $Labels/ActionStateLabel
@onready var owner_label = $Labels/OwnerLabel
@onready var tile_label = $Labels/TileLabel
@onready var ap_label = $Labels/APLabel

var grid_service: GridService
var unit_manager: UnitManager
var cover_service: CoverService
var navigation_graph_service: NavigationGraphService

var current_tile := Vector2i(-1, -1)
var target_tile := Vector2i(-1, -1)

var id: String = ""
var team_id: String = ""
var move_speed := 40.0
var orientation := "SE"
var view_angle := 90.0
var view_range := 12

signal movement_finished

const SOLDIER_HIT_SFX: AudioStream = preload("res://assets/audio/SoldierHit.wav")
const SOLDIER_DIES_SFX: AudioStream = preload("res://assets/audio/SoldierDies.wav")

func _ready() -> void:
	health_component.connect("health_changed", _on_health_changed)
	health_component.connect("died", _on_died)

	ap_component.connect("ap_changed", _on_ap_changed)
	ap_component.connect("ap_exhausted", _on_ap_exhausted)

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
	owner_label.text = team_id_
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
	AudioService.play_sfx(SOLDIER_DIES_SFX)
	set_state("DeadState", {"unit": self })


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
	unit_manager.on_unit_orientation_changed(self , new_orientation)
	queue_redraw()
	
func apply_damage(amount: int):
	# play sfx
	AudioService.play_sfx(SOLDIER_HIT_SFX)
	health_component.take_damage(amount)

func _draw():
	pass
	#print("Grid service %s for unit %s %s" % [grid_service, id, self])
	#var dst_tile = grid_service.ORIENTATION_VECTORS[orientation] * 4
	#var pos = grid_service.tile_delta_to_world_delta(dst_tile)
	#draw_line(Vector2.ZERO, pos, Color.BLUE, 2)
	#queue_redraw()

func update_state_label(state_name: String):
	state_label.text = state_name

func update_tile_label():
	tile_label.text = str(current_tile)

func update_ap_label():
	ap_label.text = "AP: %s" % ap_component.get_ap()

# func play_animation(name):
# 	sprite.play(name)

func stop_animation():
	sprite.stop()

func set_selected(selected: bool) -> void:
	#print("Selected: %s" % selected)
	sprite_selected.visible = selected


func move_to_tile(tile: Vector2i):
	print("Unit %s instructed to move to tile %s" % [id, tile])
	target_tile = tile
	# calculate new orientation
	var delta = target_tile - current_tile
	var new_ori = grid_service.get_orientation(current_tile, target_tile)
	set_orientation(new_ori)
	#set_state("MoveState", {"unit": self})
	#
	#set_process(true)

func on_arrived_to_tile(tile: Vector2i):
	print("Unit %s arrived to tile %s" % [id, tile])
	#use ap 
	ap_component.use_ap(1)
	update_ap_label()

	unit_manager.on_unit_reached_tile(self , tile)

func on_movement_finished() -> void:
	#set_process(false)
	emit_signal("movement_finished")

#region AP handling
func _on_ap_changed(current: int, max: int) -> void:
	print("Unit %s ap changed: %s/%s" % [id, current, max])
	
func _on_ap_exhausted() -> void:
	print("Unit %s ap exhausted" % id)
#endregion

#region cover
# Returns true if the unit has ANY cover in ANY direction
func is_in_cover() -> bool:
	return cover_service.get_cover_value(current_tile) > 0.0

# Returns true if the unit has cover AGAINST a specific enemy
func is_in_cover_against_enemy(enemy_unit) -> bool:
	return cover_service.get_cover_against(current_tile, enemy_unit.current_tile) > 0.0

# Finds the best cover tile relative to a specific enemy
func find_best_cover(enemy_unit) -> Vector2i:
	var best_tile := current_tile
	var best_cover := cover_service.get_cover_against(current_tile, enemy_unit.current_tile)

	# TODO: get_reachable_tiles not yet implemented
	for tile in navigation_graph_service.get_reachable_tiles(self , 4.0):
		var cover = cover_service.get_cover_against(tile, enemy_unit.current_tile)
		if cover > best_cover:
			best_cover = cover
			best_tile = tile
	return best_tile


#endregion
