extends Node
class_name IdleState

var machine: CombatStateMachine
# Injected by CombatStateMachine
var combat_scene: Node2D

func _ready():
	machine = get_parent()
	
func enter(prev):
	print("Entered idle state")

func exit(next):
	print("Exiting idle state")

func handle_click(tile: Vector2i, button_index: int):
	if button_index == MOUSE_BUTTON_LEFT:
		# Check if there is a unit in this tile:
		var units: Array = combat_scene.tile_occupancy_service.get_units(tile)
		if units.size() > 0:
			var next = machine.get_node("UnitSelectedState")
			next.selected_unit = units[0] # For now each tile can only have one unit
			machine.set_state(next)
		else:
			print("IDLE: No unit found in tile %s" % tile)
