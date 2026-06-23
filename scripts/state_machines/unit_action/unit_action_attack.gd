extends GenericState
class_name UnitActionAttackState

var unit: Unit = null
var target_tile: Vector2i
var has_fired: bool = false
var weapon_service: WeaponService

func enter(params = {}):
	print("UnitActionAttackState: enter")
	unit = params.unit
	weapon_service = params.weapon_service
	target_tile = params.target_tile
	has_fired = false

	# Rotate unit toward target

	# Play attack animation

	_spawn_projectile()

func exit(params = {}):
	pass

func update(delta: float):
	pass

func handle_click(tile: Vector2i, button_index: int):
	pass

func _spawn_projectile():
	var weapon = unit.weapon
	weapon_service.fire_bullet(
		weapon.BULLET_SCENE,
		unit.current_tile,
		target_tile,
		unit)

	# Projectile will emit "hit" → UnitManager handles damage

func _on_animation_finished():
	state_machine.set_state("IdleState")
