extends GenericState
class_name UnitBehaviorAdvance

var unit: Unit = null

func enter(params = {}):
    var tile = unit.find_advance_tile()
    unit.move_to(tile)

func exit(params = {}):
    pass

func update(delta: float):
    if unit.has_finished_moving():
        state_machine.set_state("UnitBehaviorEvaluate")
