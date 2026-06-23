extends Node2D
class_name Unit

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var sprite_selected = $SpriteSelected
@onready var action_sm = $ActionStateMachine
@onready var weapon_service: WeaponService
@onready var weapon: WeaponComponent = $WeaponComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var hp_bar: HpBar = $HpBar
@onready var ap_bar: ApBar = $ApBar

@onready var ap_component: ApComponent = $ApComponent
@onready var unit_ai: UnitAI = $UnitAI

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
var is_alive := true

signal movement_finished
signal unit_arrived_to_tile(unit, tile: Vector2i)

const SOLDIER_HIT_SFX: AudioStream = preload("res://assets/audio/SoldierHit.wav")
const SOLDIER_DIES_SFX: AudioStream = preload("res://assets/audio/SoldierDies.wav")

func _ready() -> void:
	call_deferred("_wire_signals")
	#Initialize bar
	hp_bar.update_value(health_component.current_health, health_component.max_health)
	#set_process(false)

func inject_dependencies() -> void:
	pass


func _wire_signals() -> void:
	unit_arrived_to_tile.connect(unit_manager._on_unit_arrived_to_tile)
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)

	ap_component.ap_changed.connect(_on_ap_changed)
	ap_component.ap_exhausted.connect(_on_ap_exhausted)


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


func set_soldier_type(_id: String):
	pass
	
func get_current_action():
	return action_sm.current_state.name


func _on_health_changed(current: int, max_: int):
	#hp_bar.visible = current < max_ # hide health bar when at full health
	hp_bar.update_value(current, max_)

func _on_died():
	hp_bar.visible = false
	AudioService.play_sfx(SOLDIER_DIES_SFX)
	set_state("DeadState", {"unit": self})


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

#region orientation
func set_orientation(new_orientation: String):
	#print("Unit: Setting orientation to %s" % new_orientation)
	orientation = new_orientation
	sprite.set_animation(new_orientation)
	unit_manager.on_unit_orientation_changed(self, new_orientation)
	queue_redraw()

func turn_right(amount: int) -> void:
	var new_ori = grid_service.turn_right(orientation, amount)
	set_orientation(new_ori)

func turn_left(amount: int) -> void:
	var new_ori = grid_service.turn_left(orientation, amount)
	set_orientation(new_ori)

#endregion


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
	if selected:
		navigation_graph_service.get_reachable_tiles(self, 7.0)
	sprite_selected.visible = selected


func move_to_tile(tile: Vector2i):
	#print("Unit %s instructed to move to tile %s" % [id, tile])
	target_tile = tile
	# calculate new orientation
	#var delta = target_tile - current_tile
	var new_ori = grid_service.get_orientation(current_tile, target_tile)
	set_orientation(new_ori)
	#set_state("MoveState", {"unit": self})
	#
	#set_process(true)


func _on_unit_arrived_to_tile(tile: Vector2i):
	#print("Unit: Unit arrived to tile")
	unit_arrived_to_tile.emit(self, tile)
	

func compute_visible_enemies():
	pass

func on_movement_finished() -> void:
	#set_process(false)
	emit_signal("movement_finished")

#region AP
func _on_ap_changed(current: int, max_: int) -> void:
	#ap_bar.visible = current < max_ 
	ap_bar.update_value(current, max_)
	
func _on_ap_exhausted() -> void:
	print("Unit %s ap exhausted" % id)

func get_ap() -> int:
	return ap_component.current_ap

#endregion

#region cover


func get_health_ratio() -> float:
	return health_component.get_health_ratio()

#endregion


# TODO: This functions need implementation for the UnitAI to work


# Used in AdvanceState. 
func find_advance_tile(enemy_tile: Vector2i):
	return Vector2i(0, 0)

# TODO: Needs to be implemented, not here but in unit_manager
func has_good_shoot(enemy: Unit) -> bool:
	return true
