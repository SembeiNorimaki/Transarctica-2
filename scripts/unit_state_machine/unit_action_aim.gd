extends GenericState
class_name UnitActionAimState

func enter(params = {}):
	print("UnitSM entered aim state")
	var unit: Unit = params["unit"]
	unit.play_animation(unit.get_current_action(), unit.orientation)

func exit(params = {}):
	pass

func update(delta: float):
	pass

func handle_click(tile: Vector2i, button_index: int):
	pass
