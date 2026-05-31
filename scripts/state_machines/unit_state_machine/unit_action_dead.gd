extends GenericState

class_name UnitActionDeadState

func enter(params = {}):
	print("UnitSM enter state Dead")
	if params.has("unit"):
		var unit: Unit = params["unit"]
		unit.torso.visible = false
		unit.legs.visible = false
		unit.left_arm.visible = false
		unit.right_arm.visible = false
		unit.weapon.visible = false
		unit.dead_part.visible = true
		print("Unit current action:", unit.get_current_action())
		unit.play_animation(unit.get_current_action(), unit.orientation)

func exit(params = {}):
	pass

func update(delta: float):
	pass

func handle_click(tile: Vector2i, button_index: int):
	pass
