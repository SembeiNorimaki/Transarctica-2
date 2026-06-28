extends Node
class_name FactionAI

# Injected by CombatScene
var unit_manager: UnitManager

var enemy_units = []
var current_index := 0

#signal turn_finished
signal faction_finished

func _ready() -> void:
    pass

func take_turn():
    print("FactionAI TakeTurn started")
    enemy_units = unit_manager.get_units_by_team("Enemy")
    current_index = 0
    run_next_unit()

    # print("  FactionAI: Start enemy turn")
    # var enemy_units = unit_manager.get_units_by_team("Enemy")
    # var idx := 0
    # for unit in enemy_units:
    #     print("    Running CPU unit %s" % idx)
    #     # 1) Select the unit visually, 
    #     unit_manager.select_unit(unit)
    #     # 2) Wait some time
    #     await get_tree().create_timer(1.0).timeout
    #     # # 3) Run the unit's AI turn
    #     await unit.unit_ai.take_turn()
    #     idx += 1
    # print("  FactionAI: Finished enemy turn")
    # #turn_finished.emit()


func run_next_unit():
    if current_index >= enemy_units.size():
        print("FactionAI: No more units to run")
        faction_finished.emit()
        return

    var unit = enemy_units[current_index]
    unit.unit_ai.turn_finished.connect(_on_unit_finished, CONNECT_ONE_SHOT)
    unit.set_selected(true)
    #await get_tree().create_timer(1.0).timeout
    unit.unit_ai.take_turn()


func _on_unit_finished():
    print("FactionAI _on_unit_finished called")
    current_index += 1
    run_next_unit()

# func _run_turn():
#     print("UnitAIManager execute turn")
#     var enemy_units = unit_manager.get_units_by_team("Enemy")
#     for enemy_unit in enemy_units:
#         print(enemy_unit.id)
#         dumb_unit_action(enemy_unit)

# func dumb_unit_action(unit: Unit):
#     # just move the unit 2 tiles west
#     var preview_path : Array[Vector2i] = [
#         unit.current_tile + Vector2i(0, 0),
#         unit.current_tile + Vector2i(-1, 0),
#         unit.current_tile + Vector2i(-2, 0)
#     ]

#     unit_manager.start_unit_movement(unit, preview_path)
