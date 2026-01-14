extends Node
class_name EnemyTurnState

var tm: TurnManager
var units := []
var index := 0
var parent_scene: TurnManager


func _init(turn_manager):
    tm = turn_manager

func enter(prev, params = {}):
    units = tm.unit_manager.get_units_for_team("enemy")
    units = units.filter(func(u): return not u.is_dead())
    index = 0

    tm.emit_signal("turn_started", "enemy")
    _activate_next_unit()

func _activate_next_unit():
    if index >= units.size():
        tm.emit_signal("turn_ended", "enemy")
        tm.finish_turn()
        return

    var unit = units[index]
    tm.emit_signal("unit_activated", unit)

    # Later: AI controller goes here
    # ai_controller.take_turn(unit)

func on_unit_finished():
    tm.emit_signal("unit_finished", units[index])
    index += 1
    _activate_next_unit()

func exit(next, params = {}):
    pass
