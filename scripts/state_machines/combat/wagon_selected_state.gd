extends GenericState
class_name WagonSelectedState

# The wagon node that was clicked
var selected_wagon: Node = null
var selected_wagon_id: int = -1

func _ready() -> void:
    state_machine = get_parent()

func enter(params = {}) -> void:
    selected_wagon_id = params.get("wagon_id", -1)
    selected_wagon = params.get("wagon", null)
    owner_node.master_hud.show_hud("WagonHUD", {"wagon_id": selected_wagon_id})
    if selected_wagon:
        selected_wagon.on_click()

func exit(params = {}) -> void:
    owner_node.master_hud.hide_all()

func update(delta: float) -> void:
    pass

func handle_click(tile: Vector2i, button_index: int) -> void:
    if button_index == MOUSE_BUTTON_LEFT:
        # If a player unit is in the tile, select it directly
        var units: Array = owner_node.tile_occupancy_service.get_units(tile)
        if units.size() > 0 and units[0].team_id == "Player":
            state_machine.set_state("UnitSelectedState", {"selected_unit": units[0]})
        else:
            # Clicking empty map deselects the wagon
            state_machine.set_state("IdleState")

func handle_key(event: InputEventKey) -> void:
    if event.is_action_pressed("ui_cancel"):
        state_machine.set_state("IdleState")
