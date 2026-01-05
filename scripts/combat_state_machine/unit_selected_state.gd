extends Node
class_name UnitSelectedState

var state_machine: StateMachine
# Injected by CombatStateMachine
var parent_scene: Node2D
var selected_unit: Unit = null

var preview_tile: Vector2i = Vector2i(-1, -1)
var preview_path: Array[Vector2i] = []

func _ready():
	state_machine = get_parent()
	
func enter(prev):
	print("Entered unit selected state with unit %s" % selected_unit)
	print(parent_scene.selection_manager)
	parent_scene.selection_manager.select_unit(selected_unit)

func exit(next):
	print("Exiting unit selected state")
	parent_scene.selection_manager.clear_selection()

func handle_click(tile: Vector2i, button_index: int):
	if button_index == MOUSE_BUTTON_LEFT:
		# Check if there is a unit in this tile:
		var units: Array = parent_scene.tile_occupancy_service.get_units(tile)

		# case 1: clicked on a tile without units:
		if units.size() == 0:
			state_machine.set_state("IdleState")

		# case 2: clicked on the same unit -> deselect it
		elif units[0] == selected_unit:
			state_machine.set_state("IdleState")
		
		# case 3: clicked a different unit -> select it
		elif units[0] != selected_unit:
			var next = state_machine.states["UnitSelectedState"]
			next.selected_unit = units[0]
			state_machine.set_state("UnitSelectedState")
	
	elif button_index == MOUSE_BUTTON_RIGHT:
		# Clicked on the same tile -> confirm path
		if tile == preview_tile and preview_path.size() > 0:
			_confirm_move()
			return
		# Otherwise calculate new path
		var pathfinder = parent_scene.pathfinding_service
		var unit_manager = parent_scene.unit_manager
		var unit_tile = unit_manager.get_unit_tile(selected_unit)
		var path = pathfinder.find_path(unit_tile, tile)

		if path.is_empty():
			# clear stuff
			preview_tile = Vector2i(-1, -1)
			preview_path.clear()
			parent_scene.paths_overlay.clear_path()
			return
		
		# store preview tile and path
		preview_tile = tile
		preview_path = path
		
		# draw path overlay
		parent_scene.paths_overlay.show_path(path)


func _confirm_move():
	# Order the unit to move
	var unit_manager = parent_scene.unit_manager
	unit_manager.start_unit_movement(selected_unit, preview_path)

	# Clear preview
	#preview_tile = Vector2i(-1, -1)
	#preview_path.clear()
	#parent_scene.paths_overlay.clear_path()

	# Transition to moving state
	state_machine.set_state("UnitMovingState")
