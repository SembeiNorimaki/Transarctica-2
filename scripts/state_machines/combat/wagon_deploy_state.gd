extends GenericState
class_name WagonDeployState

# Injected by CombatStateMachine via set_owner_node
# owner_node is the CombatScene

# The GameState id of the specific soldier being deployed (e.g. "s0")
var unit_id: String = ""

# The unit type to deploy (e.g. "unit_xcom")
var unit_type: String = "unit_xcom"

# The wagon from which units are being deployed
var wagon: Node = null

# The valid spawn tiles calculated from the wagon's current position
var spawn_tiles: Array[Vector2i] = []

# Offsets relative to the wagon tile (tiles "above" the wagon in isometric coords)
const SPAWN_OFFSETS: Array[Vector2i] = [
    Vector2i(-1, -2),
    Vector2i(0, -2),
    Vector2i(1, -2),
]

func enter(params = {}) -> void:
    unit_id  = params.get("unit_id", "")
    unit_type = params.get("unit_type", "unit_xcom")
    wagon = params.get("wagon", null)
    _calculate_spawn_tiles()
    _highlight_spawn_tiles()
    print("[WagonDeployState] entered. wagon=%s  spawn_tiles=%s" % [wagon, spawn_tiles])

func exit(params = {}) -> void:
    _clear_spawn_tiles()

func update(delta: float) -> void:
    pass

func handle_click(tile: Vector2i, button_index: int) -> void:
    if button_index == MOUSE_BUTTON_LEFT:
        print("[WagonDeployState] click tile=%s  spawn_tiles=%s" % [tile, spawn_tiles])
        if tile in spawn_tiles:
            _deploy_unit(tile)
        # Any click (hit or miss) exits deploy state
        state_machine.set_state("IdleState")

func handle_key(event: InputEventKey) -> void:
    # Escape cancels the deploy
    if event.is_action_pressed("ui_cancel"):
        state_machine.set_state("IdleState")

# Converts the wagon's live world position to a tile, then applies spawn offsets
func _calculate_spawn_tiles() -> void:
    spawn_tiles.clear()
    if wagon == null:
        return
    var wagon_tile: Vector2i = owner_node.grid_service.world_to_tile(wagon.global_position)
    print("[WagonDeployState] wagon.global_position=%s  wagon_tile=%s" % [wagon.global_position, wagon_tile])
    for offset in SPAWN_OFFSETS:
        var candidate: Vector2i = wagon_tile + offset
        var inside = owner_node.grid_service.is_inside_map(candidate)
        print("[WagonDeployState]   candidate=%s  inside=%s" % [candidate, inside])
        if inside:
            spawn_tiles.append(candidate)

func _highlight_spawn_tiles() -> void:
    # Reuse the reachable_tiles_overlay with an empty came_from dict (no path arrows)
    owner_node.reachable_tiles_overlay.show_tiles(spawn_tiles, {})

func _clear_spawn_tiles() -> void:
    owner_node.reachable_tiles_overlay.clear()

func _deploy_unit(tile: Vector2i) -> void:
    owner_node.unit_manager.spawn_unit(tile, unit_type, "Player")
    # Remove the soldier from the barracks wagon in GameState
    if unit_id != "":
        GameState.remove_unit_from_barracks(unit_id)
    # Refresh WagonHUD so the portrait disappears
    var wagon_id: int = owner_node.horizontal_train_manager.player_train.wagons.find(wagon)
    if wagon_id >= 0:
        owner_node.wagon_hud.setup({"wagon_id": wagon_id})
