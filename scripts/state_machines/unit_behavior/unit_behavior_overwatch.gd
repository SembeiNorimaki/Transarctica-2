extends GenericState
class_name UnitBehaviorOverwatch

var unit: Unit = null

func enter(params = {}):
    unit.enter_overwatch()
    unit.end_turn()
    state_machine.set_state("UnitBehaviorIdle")

func exit(params = {}):
    pass

func update(delta: float):
    pass
