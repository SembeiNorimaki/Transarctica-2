extends GenericState
class_name PlayerTurnState

var tm: TurnManager
var units := []
var index := 0

func _init(tm_: TurnManager) -> void:
    tm = tm_


func enter(params = {}):
    print("Player Turn State Enter")
    units = tm.unit_manager.get_units_by_team("player")
    print("EnterEnemyturnstate.Enemyunits: %s" % units)
    index = 0
    tm.emit_signal("turn_started", "player")
    _activate_next_unit()

func exit(params = {}) -> void:
    pass

func _activate_next_unit():
    if index >= units.size():
        tm.emit_signal("turn_ended", "player")
        tm.finish_turn()
        return
    
    var unit = units[index]
    tm.selection_manager.select_unit(unit)
    tm.emit_signal("unit_activated", unit)

func on_unit_finished() -> void:
    tm.emit_signal("unit_finished", units[index])
    index += 1
    _activate_next_unit()
