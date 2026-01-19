extends GenericState
class_name AimingState

# Injected by CombatStateMachine
var los_service: LOSService

var selected_unit: Unit = null

func _ready():
	pass

func enter(params = {}):
	print("Enter AimingState with params %s" % params)
	selected_unit = params["selected_unit"]

func exit(params = {}):
	pass

func update(delta: float):
	pass

func _attempt_shot(tile: Vector2i):
	var shooter = selected_unit
	var shooter_tile = shooter.current_tile
	var target_tile = tile

	if not los_service.has_los(shooter_tile, target_tile):
		print("NO LOS")
		return
	shooter.weapon.shoot(target_tile)
	
	
func handle_click(tile: Vector2i, button_index: int):
	print("CUAS click %s" % tile)
	_attempt_shot(tile)


func handle_key(event: InputEventKey):
	print("CUAS handle key %s" % event)
	if event.is_action_pressed("tab"):
		owner_node.select_next_unit()
