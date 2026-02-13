extends GenericState
class_name AimingState

# Injected by CombatStateMachine
var los_service: LOSService
var weapon_service: WeaponService


var selected_unit: Unit = null

var prev_mouse_tile := Vector2i(-1, -1)

var BULLET_SCENE = preload("res://scenes/entities/projectiles/bullet.tscn")

func _ready():
	#weapon_service = owner_node.weapon_service
	#los_service = owner_node.los_service
	#print("CUAS ready, owner_node: %s" % owner_node)
	pass
func enter(params = {}):
	print("Enter AimingState with params %s" % params)
	selected_unit = params["selected_unit"]
	owner_node.set_cursor("aim")

func exit(params = {}):
	pass

func update(delta: float):
	var mouse_tile = owner_node.grid_service.world_to_tile(owner_node.get_global_mouse_position())
	if mouse_tile != prev_mouse_tile:
		prev_mouse_tile = mouse_tile
		var mouse_world_position = owner_node.grid_service.tile_to_world(mouse_tile)
		owner_node.aim_cursor.global_position = mouse_world_position
		var has_los = owner_node.los_service.has_los(selected_unit.current_tile, mouse_tile)
		print(has_los)
		

func _attempt_shot(tile: Vector2i):
	var shooter = selected_unit
	var shooter_tile = shooter.current_tile
	var target_tile = tile

	#print("Attempting shoot: Shooter %s, from %s to %s" % [shooter, shooter_tile, target_tile])

	owner_node.los_service.bresenham_line(shooter_tile, target_tile)
	#if not los_service.has_los(shooter_tile, target_tile):
	#	#print("NO LOS")
	#	return
	owner_node.weapon_service.fire_bullet(BULLET_SCENE, shooter_tile, target_tile, shooter)
	
	
func handle_click(tile: Vector2i, button_index: int):
	#print("CUAS click %s" % tile)
	_attempt_shot(tile)


func handle_key(event: InputEventKey):
	#print("CUAS handle key %s" % event)
	if event.is_action_pressed("tab"):
		owner_node.select_next_unit()
