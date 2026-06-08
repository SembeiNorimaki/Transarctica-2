extends GenericState
class_name UnitSelectedState

var selected_unit: Unit = null

var preview_tile: Vector2i = Vector2i(-1, -1)
var preview_path: Array[Vector2i] = []

func _ready():
	state_machine = get_parent()
	
func enter(params = {}):
	print("Enter CombatUnitSelectedState with params %s" % params)
	selected_unit = params["selected_unit"]
	owner_node.selection_manager.select_unit(selected_unit)
	owner_node.camera_controller.center_at_tile(selected_unit.current_tile)

func exit(params = {}):
	pass
	#print("Exiting unit selected state")
	#parent_scene.selection_manager.clear_selection()
func update(delta: float):
	pass

func _confirm_move():
	# Order the unit to move
	var unit_manager = owner_node.unit_manager
	print("Confirm path ", preview_path)
	unit_manager.start_unit_movement(selected_unit, preview_path)

	# Clear preview
	#preview_tile = Vector2i(-1, -1)
	#preview_path.clear()
	#parent_scene.paths_overlay.clear_path()

	# Transition to moving state
	state_machine.set_state("UnitMovingState", {"selected_unit": selected_unit})


func handle_click(tile: Vector2i, button_index: int):
	# Movement like XCOM:
	# Left click: 
	#    If click on an unit, select it
	#    If click on a tile, calculate path to it
	#    If clicked again on the same tile, confirm path
	# Right click:
	#    Rotate unit so it looks in this direction
	if button_index == MOUSE_BUTTON_RIGHT:
		var new_orientation = owner_node.grid_service.get_orientation(selected_unit.current_tile, tile)
		selected_unit.set_orientation(new_orientation)
	elif button_index == MOUSE_BUTTON_LEFT:
		# Check if there is a unit in this tile:
		var units: Array = owner_node.tile_occupancy_service.get_units(tile)
		
		# case 1: clicked on a tile with a different unit -> select it
		if units.size() > 0 and units[0] != selected_unit and units[0].team_id == "Player":
			state_machine.set_state("UnitSelectedState", {"selected_unit": units[0]})
		# case 2: Clicked on a tile without units
		elif units.size() == 0:
			# Clicked on the same tile -> confirm path
			if tile == preview_tile and preview_path.size() > 0:
				_confirm_move()
				return

			# Otherwise calculate new path
			var pathfinder = owner_node.pathfinding_service
			var unit_manager = owner_node.unit_manager
			var unit_tile = unit_manager.get_unit_tile(selected_unit)
			var path_and_cost = pathfinder.find_path(unit_tile, tile)
			var path = path_and_cost[0]
			var path_cost = path_and_cost[1]


			if path.is_empty():
				# clear stuff
				preview_tile = Vector2i(-1, -1)
				preview_path.clear()
				owner_node.paths_overlay.clear_path()
				return
		
			# store preview tile and path
			preview_tile = tile
			#path.pop_front()  # remove the first element of the path, since it's the current tile
			preview_path = path
			
			# draw path overlay
			owner_node.paths_overlay.show_path(path, path_cost)
			

	# if button_index == MOUSE_BUTTON_LEFT:
	# 	# Check if there is a unit in this tile:
	# 	var units: Array = owner_node.tile_occupancy_service.get_units(tile)

	# 	# case 1: clicked on a tile without units:
	# 	if units.size() == 0:
	# 		state_machine.set_state("IdleState")

	# 	# case 2: clicked on the same unit -> deselect it
	# 	elif units[0] == selected_unit:
	# 		state_machine.set_state("IdleState")
		
	# 	# case 3: clicked a different unit -> select it
	# 	elif units[0] != selected_unit:
	# 		state_machine.set_state("UnitSelectedState", units[0])
	
	# elif button_index == MOUSE_BUTTON_RIGHT:
	# 	# Clicked on the same tile -> confirm path
	# 	if tile == preview_tile and preview_path.size() > 0:
	# 		_confirm_move()
	# 		return
	# 	# Otherwise calculate new path
	# 	var pathfinder = owner_node.pathfinding_service
	# 	var unit_manager = owner_node.unit_manager
	# 	var unit_tile = unit_manager.get_unit_tile(selected_unit)
	# 	var path = pathfinder.find_path(unit_tile, tile)

	# 	if path.is_empty():
	# 		# clear stuff
	# 		preview_tile = Vector2i(-1, -1)
	# 		preview_path.clear()
	# 		owner_node.paths_overlay.clear_path()
	# 		return
		
	# 	# store preview tile and path
	# 	preview_tile = tile
	# 	#path.pop_front()  # remove the first element of the path, since it's the current tile
	# 	preview_path = path
		
	# 	# draw path overlay
	# 	owner_node.paths_overlay.show_path(path)

# q toggles aim
# c toggles crouch
func handle_key(event: InputEventKey):
	if event.is_action_pressed("tab"):
		owner_node.select_next_unit()
	elif event.is_action_pressed("q"):
		print("Action pressed q")
		state_machine.set_state("UnitAimingState", {"selected_unit": selected_unit})
	elif event.is_action_pressed("c"):
		print("Action pressed c")
		selected_unit.toggle_crouch()
