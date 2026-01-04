extends Node

var selected_unit: Unit = null

func select_unit(unit: Unit) -> void:
    if selected_unit:
        selected_unit.set_selected(false)
    selected_unit = unit
    if selected_unit:
        selected_unit.set_selected(true)

func clear_selection() -> void:
    if selected_unit:
        selected_unit.set_selected(false)
    selected_unit = null

func get_selected_unit() -> Unit:
    return selected_unit