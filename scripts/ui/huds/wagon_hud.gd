extends Control
class_name WagonHUD

# Injected by CombatScene
var wagon_manager: WagonManager = null

@onready var portrait: TextureRect = $HBoxContainerLeft/Portrait
@onready var content_container: HBoxContainer = $HBoxContainerCenter

const PORTRAITS: Dictionary = {
    "LocomotiveWagon": preload("res://assets/sprites/wagons/trade/locomotive_tr.png"),
    "TenderWagon": preload("res://assets/sprites/wagons/trade/tender_tr.png"),
    "BarracksWagon": preload("res://assets/sprites/wagons/trade/barracks_tr.png"),
    "CannonWagon": preload("res://assets/sprites/wagons/trade/cannon_tr.png"),
    "MerchandiseWagon": preload("res://assets/sprites/wagons/trade/merchandise_tr.png"),
}

# Map wagon type → panel scene. Add new entries here as wagon types grow.
const PANELS: Dictionary = {
    "BarracksWagon":    preload("res://scenes/ui/panels/barracks_panel.tscn"),
    "MerchandiseWagon": preload("res://scenes/ui/panels/merchandise_panel.tscn"),
    "TenderWagon":      preload("res://scenes/ui/panels/tender_panel.tscn"),
    "LocomotiveWagon":  preload("res://scenes/ui/panels/locomotive_panel.tscn"),
}

var _current_wagon_id: int = -1

func setup(params: Dictionary) -> void:
    var wagon_id: int = params.get("wagon_id", -1)
    if wagon_id < 0:
        return

    _current_wagon_id = wagon_id
    var wagon_data: Dictionary = GameState.get_player_train().wagons[wagon_id]
    var wagon_type: String = wagon_data.get("type", "")

    # Update wagon portrait
    portrait.texture = PORTRAITS.get(wagon_type, null)

    # Swap in the right content panel
    _clear_content()
    var panel_scene: PackedScene = PANELS.get(wagon_type, null)
    if panel_scene:
        var panel = panel_scene.instantiate()
        content_container.add_child(panel)
        panel.setup(wagon_data, wagon_id, wagon_manager)

func _clear_content() -> void:
    for child in content_container.get_children():
        child.queue_free()
