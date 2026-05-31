extends GenericState
class_name IdleState


func _ready():
	pass
	
func enter(params = {}):
	pass

func exit(params = {}):
	pass

func update(delta: float):
	pass

func handle_click(tile: Vector2i, button_index: int):
	if button_index == MOUSE_BUTTON_LEFT:
		# Check if there is a unit in this tile:
		var units: Array = owner_node.tile_occupancy_service.get_units(tile)
		if units.size() > 0 and units[0].team_id == "Player":
			state_machine.set_state("UnitSelectedState", {"selected_unit": units[0]})
		else:
			pass
			#print("IDLE: No unit found in tile %s" % tile)
func handle_key(event: InputEventKey):
	if event.is_action_pressed("tab"):
		owner_node.select_next_unit()
	elif event.is_action_pressed("q"):
		pass
		#print("A pressed")
