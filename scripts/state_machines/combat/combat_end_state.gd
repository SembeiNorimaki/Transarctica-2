extends GenericState
class_name CombatEndState

var result: String = "" # "victory" or "defeat"

func enter(params = {}):
    result = params.get("result", "")
    owner_node.show_end_screen(result)

func exit(params = {}):
    pass

func update(delta: float):
    pass

# Block all input while the combat is over
func handle_click(_tile: Vector2i, _button_index: int):
    pass

func handle_key(_event: InputEventKey):
    pass
