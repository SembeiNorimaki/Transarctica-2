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

# Remaining candidates to try if the current one fails
var _remaining_candidates: Array = []

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
        0:
            action_counter += 1
            _do_action_1()
        1:
            action_counter += 1
            _do_action_2()
        _:
            push_warning("take_next_action called with no actions left")
            action_finished.emit()
    

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
    print("[Evaluate] Action 1  positioning phase")
    unit.update_action_idx_label(1)

    # ---- early-out guard ----
    if not unit.is_alive:
        action_finished.emit()
        return

    var enemies: Array = unit.unit_manager.get_seen_enemies_for(unit)

    # Build the candidate list and score every possible action
    var candidates: Array = _build_action1_candidates(enemies)
    _try_candidates(candidates)


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
# ACTION 2   Combat / aggressive actions
#
# Philosophy: the unit has repositioned (or chose not to). Now it should act.
# Shooting a good target is the top priority. Overwatch is a solid fallback.
# ---------------------------------------------------------------------------

func _do_action_2() -> void:
    print("[Evaluate] Action 2  combat phase")
    unit.update_action_idx_label(2)

    if not unit.is_alive:
        action_finished.emit()
        return

    var enemies: Array = unit.unit_manager.get_seen_enemies_for(unit)

    var candidates: Array = _build_action2_candidates(enemies)
    _try_candidates(candidates)


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


## Tries candidates in score order, retrying the next-best if one fails.
func _try_candidates(candidates: Array) -> void:
    var best = _pick_best_candidate(candidates)
    if best == null:
        print("[Evaluate] No viable candidate left, emitting action_finished")
        action_finished.emit()
        return
    candidates.erase(best)
    _remaining_candidates = candidates
    # Connect action_failed one-shot so we fall back if this state can't execute
    var action: String = best.action
    if state_machine.states.has(action) and state_machine.states[action].has_signal("action_failed"):
        state_machine.states[action].action_failed.connect(_on_candidate_failed, CONNECT_ONE_SHOT)
    print("[Evaluate] Trying: %s (score %.1f)" % [best.label, best.score])
    _execute_candidate(best)


func _on_candidate_failed() -> void:
    print("[Evaluate] Candidate failed, trying next best")
    _try_candidates(_remaining_candidates)


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
            # action_finished is emitted via unit.shot_completed when the bullet lands,
            # mirroring how _on_unit_reached_destination works for movement actions.
            unit.shot_completed.connect(action_finished.emit, CONNECT_ONE_SHOT)
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


# OLD stuff

# func evaluate_xcom1():
#     # 1) Dead?
#     # print("1) Checking if unit is dead")
#     if not unit.is_alive:
#         unit.unit_ai.turn_finished.emit()
#         return

#     # 2) No AP?
#     # print("2) Checking if unit has enough AP")
#     # TODO: Instead of checking against 0, there should be a minimum amount of AP left
#     if unit.get_ap() <= 0:
#         unit.unit_ai.turn_finished.emit()
#         return
    
#     # 3) Enemy visible?
    
#     var enemy = unit.unit_manager.get_primary_target_for(unit)
#     # print("3) Checking if an enemy is visible... %s" % ("Yes" if enemy else "No"))
#     if enemy == null:
#         # No enemy visible, enter overwatch
#         state_machine.set_state("OverwatchState", {"unit": unit})
#         return
    
#     # 4) Low health -> Retreat or seek cover
#     # TODO: Needs to be checked
#     # print("4) Checking unit health ratio: %s" % unit.get_health_ratio())
#     if unit.get_health_ratio() < LOW_HEALTH_THRESHOLD:
#         var safe_tile = unit.find_safe_tile()
#         if safe_tile != unit.current_tile:
#             unit.target_tile = safe_tile
#             state_machine.set_state("RetreatState", {"unit": unit})
#             return
#         # If no safe tile exists, seek cover
#         if not unit.is_in_cover_against_enemy(enemy):
#             var cover_tile = unit.unit_manager.find_best_cover(unit, enemy)
#             unit.target_tile = cover_tile
#             state_machine.set_state("SeekCoverState", {"unit": unit})
#             return
#         # If already in cover, overwatch as fallback
#         state_machine.set_state("OverwatchState", {"unit": unit})
#         return
    
#     # 5) Flanked (no directional cover)
#     # TODO: Needs to be checked
#     var incover = unit.unit_manager.is_unit_in_cover_against_enemy(unit, enemy)
#     # print("5) Checking if unit is in cover: %s" % ("Yes" if incover else "No"))
#     if not incover:
#         var cover_tile = unit.unit_manager.find_best_cover(unit, enemy)
#         if cover_tile != unit.current_tile:
#             unit.target_tile = cover_tile
#             state_machine.set_state("SeekCoverState", {"unit": unit})
#             return
#         # If no cover reachable, attack if possible
#         if unit.has_good_shoot(enemy):
#             state_machine.set_state("AttackState", {"unit": unit, "target": enemy})
#             return
#         # Otherwise, advance
#         var adv_tile = unit.find_advance_tile(enemy.current_tile)
#         unit.target_tile = adv_tile
#         state_machine.set_state("AdvanceState", {"unit": unit, "target": enemy})
#         return

#     # 6) In cover and good shot -> attack
#     # print("6) Checking if unit has good shoot")
#     if unit.has_good_shoot(enemy):
#         state_machine.set_state("AttackState", {"unit": unit, "target_tile": enemy.current_tile})
#         return
    
#     # 7) In cover but no good shoot -> overwatch or advance
#     # print("7) Checking if unit is in cover but no good shoot")
#     if unit.is_in_cover_against_enemy(enemy):
#         if unit.should_overwatch():
#             state_machine.set_state("OverwatchState", {"unit": unit})
#             return
#         var adv_tile = unit.find_advance_tile(enemy.current_tile)
#         unit.target_tile = adv_tile
#         state_machine.set_state("AdvanceState", {"unit": unit, "target": enemy})
#         return
    
#     # 8) Fallback: advance
#     # print("8) Fallback: advance")
#     var adv_tile = unit.find_advance_tile(enemy.current_tile)
#     unit.target_tile = adv_tile
#     state_machine.set_state("AdvanceState", {"unit": unit, "target": enemy})
    

#     state_machine.state_finished.emit()

# action_finished.emit()  to tell unitAI to do action 2

# func _do_action_1():
#     print("Doing action 1")
#     await get_tree().create_timer(0.2).timeout
#     # Look left and right to see if there are enemies
#     unit.turn_left(1)
#     await get_tree().create_timer(0.2).timeout
#     unit.turn_right(2)
#     await get_tree().create_timer(0.2).timeout
#     unit.turn_left(1)
#     await get_tree().create_timer(0.2).timeout

#     # var target_tile = unit.current_tile + Vector2i(0, 3)
#     # var path = unit.unit_manager.calculate_path_for_unit(unit, target_tile)
#     # unit.unit_manager.start_unit_movement(unit, path)
#     # return
    

#     var enemies = unit.unit_manager.get_seen_enemies_for(unit)
#     print("Unit sees %s enemies" % enemies.size())

#     # 1) No enemies known by the unit
#     if enemies.size() == 0:
#         pass
    
#     # 2) Immediate danger: not in cover against any visible enemy
#     # works good. Unit seeks cover correctly
#     if not unit.unit_manager.is_unit_in_cover_against_all_enemies(unit, enemies):
#         print("Unit not in cover, seeking cover")
#         state_machine.set_state("SeekCoverState", {"unit": unit, "enemies": enemies})
#         return
    
#     # 3) Low health
#     if unit.get_health_ratio() < LOW_HEALTH_THRESHOLD:
#         print("Unit has lo health, retreating")
#         state_machine.set_state("RetreatState", {"unit": unit, "enemies": enemies})
#         return

#     # Select best enemy to attack
#     var enemy = unit.unit_manager.choose_best_target(unit, enemies)
#     print("Choosing best target. Enemy: %s" % enemy.id)
#     if enemy == null:
#         pass

#     # 3) Flanking opportunity
#     # print("Checking flanking opportunity")
#     # var flank_tile = unit.find_flanking_tile(enemy)
#     # if flank_tile and flank_tile != unit.current_tile:
#     #     # print("Action1: Flanking opportunity → move to flank")
#     #     unit.target_tile = flank_tile
#     #     #_perform_move()
#     #     return
    
#     # 4) Already in good cover + good shot → shoot
#     # print("Checking good shot")
#     if unit.unit_manager.has_unit_good_shoot(unit, enemy):
#         print("Good, shot, attacking")
#         state_machine.set_state("AttackState", {"unit": unit, "target_tile": enemy.current_tile})
#         return


# func _do_action_2():
#     print("Doing action 2")
#     await get_tree().create_timer(1.0).timeout
    
#     # Look left and right to see if there are enemies
#     unit.turn_left(1)
#     await get_tree().create_timer(1.0).timeout
#     unit.turn_right(2)
#     await get_tree().create_timer(1.0).timeout
#     unit.turn_left(1)
#     await get_tree().create_timer(1.0).timeout

#     var target_tile = unit.current_tile + Vector2i(2, 0)
#     var path = unit.unit_manager.calculate_path_for_unit(unit, target_tile)
#     unit.unit_manager.start_unit_movement(unit, path)
    
#     return
