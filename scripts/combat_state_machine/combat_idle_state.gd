extends Node
class_name IdleState

var machine: StateMachine
# Injected by CombatStateMachine
var parent_scene: Node2D

func _ready():
    machine = get_parent()
    
func enter(prev, params={}):
    pass

func exit(next, params={}):
    pass

func update(delta: float):
    pass

func handle_click(tile: Vector2i, button_index: int):
    if button_index == MOUSE_BUTTON_LEFT:
        # Check if there is a unit in this tile:
        var units: Array = parent_scene.tile_occupancy_service.get_units(tile)
        if units.size() > 0:
            machine.set_state("UnitSelectedState", {"selected_unit": units[0]})
        else:
            print("IDLE: No unit found in tile %s" % tile)

func handle_key(event: InputEventKey):
    if event.is_action_pressed("tab"): 
        parent_scene.select_next_unit()
    elif event.is_action_pressed("a"):
        print("A pressed")