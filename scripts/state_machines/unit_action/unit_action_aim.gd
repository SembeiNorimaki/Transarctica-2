extends GenericState
class_name UnitActionAimState

func enter(params = {}):
    var unit: Unit = params["unit"]
    unit.play_animation(unit.get_current_action(), unit.orientation)
    if params.get("auto_fire", false):
        state_machine.set_state("AttackState", {
            "unit": unit,
            "target_tile": params["target_tile"],
            "weapon_service": params["weapon_service"]
        })

func exit(params = {}):
    pass

func update(delta: float):
    pass

func handle_click(tile: Vector2i, button_index: int):
    pass
