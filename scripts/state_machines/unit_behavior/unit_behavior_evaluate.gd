extends GenericState
class_name UnitBehaviorEvaluate

# ---------------------------------------------------------------------------
# Tunable tactical thresholds
# ---------------------------------------------------------------------------
const LOW_HEALTH_THRESHOLD := 0.35 # below this, retreat is strongly preferred
const GOOD_SHOT_THRESHOLD := 0.45 # minimum hit-chance to consider a shot worthwhile
const OVERWATCH_MIN_ENEMIES := 1 # need at least this many visible enemies to bother with overwatch


# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------
var unit: Unit = null

# XCOM-2-style two-action turn counter (0 ? action 1, 1 ? action 2)
var action_counter := 0

signal action_finished


# ---------------------------------------------------------------------------
# GenericState interface
# ---------------------------------------------------------------------------

func enter(params = {}) -> void:
    unit = params.unit
    action_counter = 0
    unit.unit_manager.unit_reached_destination.connect(_on_unit_reached_destination)
    take_next_action()


func exit(params = {}) -> void:
    pass


# ---------------------------------------------------------------------------
# Action sequencing
# ---------------------------------------------------------------------------

func take_next_action() -> void:
    match action_counter:
	    0: _do_action_1()
	    1: _do_action_2()
	    _:
		    push_warning("UnitBehaviorEvaluate: take_next_action called with no actions left")
		    action_finished.emit()
		    return
    action_counter += 1


func is_anything_left_to_do() -> bool:
    return action_counter < 2


# ---------------------------------------------------------------------------
# ACTION 1  � Positioning / repositioning
#
# Philosophy: the unit should use its first action to get to a good spot.
# Aggressive actions (shooting) are possible but score lower than repositioning
# because the unit still has a second action coming and can shoot then.
# ---------------------------------------------------------------------------

func _do_action_1() -> void:
    print("[Evaluate] Action 1 � positioning phase")

	# ---- early-out guard ----
    if not unit.is_alive:
	    action_finished.emit()
	    return

    var enemies: Array = unit.unit_manager.get_seen_enemies_for(unit)

	# Build the candidate list and score every possible action
    var candidates: Array = _build_action1_candidates(enemies)
    var best = _pick_best_candidate(candidates)

    if best == null:
	    print("[Evaluate] Action 1 � no viable action, emitting action_finished")
	    action_finished.emit()
	    return

    print("[Evaluate] Action 1 � executing: %s (score %.1f)" % [best.label, best.score])
    _execute_candidate(best)


func _build_action1_candidates(enemies: Array) -> Array:
	# Each candidate is a Dictionary:
	#   { label: String, score: float, action: String, params: Dictionary }
    var candidates: Array = []

    var in_cover_vs_all: bool = unit.unit_manager.is_unit_in_cover_against_all_enemies(unit, enemies)
    var health_ratio: float = unit.get_health_ratio()

	# ---- RETREAT -----------------------------------------------------------
	# High priority when health is critical AND enemies are visible.
    if health_ratio < LOW_HEALTH_THRESHOLD and enemies.size() > 0:
	    var safe_tile: Vector2i = unit.unit_manager.find_safest_tile(unit, enemies)
	    if safe_tile != unit.current_tile:
		    candidates.append(_make_candidate(
				"Retreat",
				# Score rises sharply as health drops
			    80.0 + (1.0 - health_ratio) * 40.0,
				"RetreatState",
				{"unit": unit, "enemies": enemies}
			))

	# ---- SEEK COVER --------------------------------------------------------
	# Useful when the unit is exposed to any visible enemy.
    if enemies.size() > 0 and not in_cover_vs_all:
	    var safe_tile: Vector2i = unit.unit_manager.find_safest_tile(unit, enemies)
	    if safe_tile != unit.current_tile:
			# Urgency rises with damage taken
		    var cover_urgency := 60.0 + (1.0 - health_ratio) * 20.0
		    candidates.append(_make_candidate(
				"SeekCover",
			    cover_urgency,
				"SeekCoverState",
				{"unit": unit, "enemies": enemies}
			))

	# ---- ADVANCE -----------------------------------------------------------
	# Close in on the best target when the current shot quality is poor.
    if enemies.size() > 0:
	    var primary: Unit = unit.unit_manager.choose_best_target(unit, enemies)
	    if primary != null:
		    var hit_chance: float = unit.unit_manager.get_hit_chance_for(unit, primary)
			# Only worth advancing if current shot is bad
		    if hit_chance < GOOD_SHOT_THRESHOLD:
			    var advance_score := 30.0 + (GOOD_SHOT_THRESHOLD - hit_chance) * 50.0
				# Dampen if health is low (cover is more important than closing distance)
			    advance_score -= (1.0 - health_ratio) * 20.0
			    candidates.append(_make_candidate(
					"Advance",
				    max(0.0, advance_score),
					"AdvanceState",
					{"unit": unit, "target": primary}
				))

	# ---- HOLD POSITION (NO-OP) --------------------------------------------
	# Already in good cover with enemies in sight: save the action for action 2.
    if in_cover_vs_all and enemies.size() > 0:
	    candidates.append(_make_candidate(
			"HoldPosition",
		    25.0,
			"HoldPosition", # virtual; handled in _execute_candidate
			{"unit": unit}
		))

	# ---- NO ENEMIES IN SIGHT ----------------------------------------------
    if enemies.size() == 0:
	    candidates.append(_make_candidate(
			"Idle",
		    10.0,
			"HoldPosition",
			{"unit": unit}
		))

    return candidates


# ---------------------------------------------------------------------------
# ACTION 2  � Combat / aggressive actions
#
# Philosophy: the unit has repositioned (or chose not to). Now it should act.
# Shooting a good target is the top priority. Overwatch is a solid fallback.
# ---------------------------------------------------------------------------

func _do_action_2() -> void:
    print("[Evaluate] Action 2 � combat phase")

    if not unit.is_alive:
	    action_finished.emit()
	    return

    var enemies: Array = unit.unit_manager.get_seen_enemies_for(unit)

    var candidates: Array = _build_action2_candidates(enemies)
    var best = _pick_best_candidate(candidates)

    if best == null:
	    print("[Evaluate] Action 2 � no viable action, emitting action_finished")
	    action_finished.emit()
	    return

    print("[Evaluate] Action 2 � executing: %s (score %.1f)" % [best.label, best.score])
    _execute_candidate(best)


func _build_action2_candidates(enemies: Array) -> Array:
    var candidates: Array = []

	# ---- ATTACK ------------------------------------------------------------
	# Score each visible enemy individually and take the best shot.
    var best_shot_score := -INF
    var best_target: Unit = null

    for enemy in enemies:
	    var hit_chance: float = unit.unit_manager.get_hit_chance_for(unit, enemy)
	    if hit_chance <= 0.0:
		    continue # no valid shot

		# Base value: hit chance mapped to [0-100]
	    var shot_score := hit_chance * 100.0

		# Flanking bonus: enemy has no cover against us ? great shot
	    var enemy_cover: float = unit.unit_manager.get_cover_of_enemy_against(unit, enemy)
	    if enemy_cover == 0.0:
		    shot_score += 25.0

		# Prioritise finishing off wounded enemies
	    shot_score += (1.0 - enemy.get_health_ratio()) * 15.0

	    if shot_score > best_shot_score:
		    best_shot_score = shot_score
		    best_target = enemy

    if best_target != null and best_shot_score >= GOOD_SHOT_THRESHOLD * 100.0:
	    candidates.append(_make_candidate(
			"Attack -> %s" % str(best_target.get_instance_id()),
		    best_shot_score,
			"AttackState",
			{"unit": unit, "target_tile": best_target.current_tile}
		))

	# ---- OVERWATCH ---------------------------------------------------------
	# Good fallback: punish enemy movement, especially when in solid cover.
    if enemies.size() >= OVERWATCH_MIN_ENEMIES:
	    var overwatch_score := 35.0

		# Bonus: already in cover ? safer to hold and watch
	    if unit.unit_manager.is_unit_in_cover_against_all_enemies(unit, enemies):
		    overwatch_score += 20.0

		# Penalty: low health makes overwatch risky
	    overwatch_score -= (1.0 - unit.get_health_ratio()) * 15.0

	    candidates.append(_make_candidate(
			"Overwatch",
		    max(0.0, overwatch_score),
			"OverwatchState",
			{"unit": unit}
		))

	# ---- NO ENEMIES ? low-value overwatch ---------------------------------
    if enemies.size() == 0:
	    candidates.append(_make_candidate(
			"Overwatch (no enemies visible)",
		    15.0,
			"OverwatchState",
			{"unit": unit}
		))

    return candidates


# ---------------------------------------------------------------------------
# Scoring helpers
# ---------------------------------------------------------------------------

## Constructs a candidate dictionary.
func _make_candidate(label: String, score: float, action: String, params: Dictionary) -> Dictionary:
    return {"label": label, "score": score, "action": action, "params": params}


## Returns the candidate with the highest score, or null if the list is empty.
func _pick_best_candidate(candidates: Array) -> Variant:
    if candidates.is_empty():
	    return null

    var best = candidates[0]
    for c in candidates:
	    if c.score > best.score:
		    best = c
    return best


# ---------------------------------------------------------------------------
# Execution dispatch
# ---------------------------------------------------------------------------

func _execute_candidate(candidate: Dictionary) -> void:
    var action: String = candidate.action
    var params: Dictionary = candidate.params

    match action:
		"HoldPosition":
			# No movement needed; consuming this action slot and signalling done.
		    action_finished.emit()

		"RetreatState", "SeekCoverState", "AdvanceState":
			# Movement states: action_finished is emitted by _on_unit_reached_destination
			# once the unit physically arrives at its destination.
		    state_machine.set_state(action, params)

		"AttackState":
			# The attack state handles its own completion internally.
		    state_machine.set_state(action, params)

		"OverwatchState":
		    state_machine.set_state(action, params)

	    _:
		    push_warning("UnitBehaviorEvaluate: unknown action '%s'" % action)
		    action_finished.emit()


# ---------------------------------------------------------------------------
# Signal handlers
# ---------------------------------------------------------------------------

func _on_unit_reached_destination(_arriving_unit) -> void:
    action_finished.emit()


# ===========================================================================
# REQUIRED ADDITIONS IN OTHER MODULES
# ===========================================================================
#
# The scoring system calls two functions that do NOT yet exist in
# unit_manager.gd.  Prototypes, locations, and implementation notes follow.
#
# ---------------------------------------------------------------------------
# FILE:   scripts/managers/unit_manager.gd
# REGION: #region shoot  (or a new #region hit-chance)
# ---------------------------------------------------------------------------
#
# func get_hit_chance_for(shooter: Unit, target: Unit) -> float:
#     """
#     Returns a normalised hit probability in [0.0 .. 1.0].
#
#     Outline:
#       1. If not los_service.has_los(shooter.current_tile, target.current_tile):
#              return 0.0
#       2. If shooter.current_tile.distance_to(target.current_tile) > shooter.weapon.max_range:
#              return 0.0
#       3. Compute base hit: e.g. clamp(shooter.accuracy / 100.0, 0.0, 1.0)
#       4. Apply range penalty: subtract something proportional to distance.
#       5. Apply cover penalty:
#              var cover = cover_service.get_cover_against(target.current_tile, shooter.current_tile)
#              base_hit -= cover * cover_penalty_factor
#       6. return clamp(base_hit, 0.0, 1.0)
#
#     NOTE: choose_best_target() already does similar math internally;
#     extracting it here avoids duplication and lets evaluate score each
#     enemy without triggering a full target-selection pass.
#     """
#
# ---------------------------------------------------------------------------
# FILE:   scripts/managers/unit_manager.gd
# REGION: #region cover
# ---------------------------------------------------------------------------
#
# func get_cover_of_enemy_against(shooter: Unit, enemy: Unit) -> float:
#     """
#     Returns the cover value [0.0 .. 1.0] that 'enemy' has at its current tile
#     against fire coming from 'shooter'.
#
#     Outline:
#       return cover_service.get_cover_against(enemy.current_tile, shooter.current_tile)
#
#     This is a thin wrapper that makes evaluate code read clearly
#     ("how much cover does the enemy have against ME?") without exposing the
#     tile-coordinate convention of cover_service to the evaluate state.
#     """
#
# ===========================================================================
