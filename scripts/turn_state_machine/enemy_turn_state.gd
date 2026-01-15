extends GenericState
class_name EnemyTurnState

var tm: TurnManager
var units := []
var index := 0


func _init(tm_):
    tm = tm_
   
func enter(params = {}):
    print("Enemy Turn State Enter")
    units = tm.unit_manager.get_units_for_team("enemy")
    units = units.filter(func(u): return not u.is_dead())
    print("Enter Enemy turn state. Enemy units: %s" % units)
    index = 0

    tm.emit_signal("turn_started", "enemy")
    _activate_next_unit()

func exit(params = {}):
    pass

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
