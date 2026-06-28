extends GenericState
class_name UnitBehaviorRetreat

var unit: Unit = null

func enter(params = {}):
    var safe_tile = unit.find_safe_tile()
    if safe_tile:
        unit.move_to(safe_tile)

func exit(params = {}):
    pass

func update(delta: float):
    if unit.has_finished_moving():
        state_machine.set_state("UnitBehaviorEvaluate")
