extends Control
class_name WagonHUD

signal unit_deploy_requested(unit_id: String, unit_type: String)

@onready var portrait: TextureRect = $HBoxContainerLeft/Portrait
@onready var content_container: HBoxContainer = $HBoxContainerCenter

const PORTRAITS: Dictionary = {
    "LocomotiveWagon": preload("res://assets/sprites/wagons/trade/locomotive_tr.png"),
    "TenderWagon": preload("res://assets/sprites/wagons/trade/tender_tr.png"),
    "BarracksWagon": preload("res://assets/sprites/wagons/trade/barracks_tr.png"),
    "CannonWagon": preload("res://assets/sprites/wagons/trade/cannon_tr.png"),
    "MerchandiseWagon": preload("res://assets/sprites/wagons/trade/merchandise_tr.png"),
}

# Default soldier portrait — swap per unit type when you have more assets
const SOLDIER_PORTRAIT: Texture2D = preload("res://assets/sprites/soldier.png")

var current_wagon_id: int = -1

func setup(params: Dictionary) -> void:
    current_wagon_id = params.get("wagon_id", -1)
    if current_wagon_id < 0:
        return

    var wagon_data: Dictionary = GameState.get_player_train().wagons[current_wagon_id]
    var wagon_type: String = wagon_data.get("type", "")

    # Set the portrait for this wagon type
    portrait.texture = PORTRAITS.get(wagon_type, null)

    # Populate the content area based on wagon type
    _clear_content()
    if wagon_type == "BarracksWagon":
        _populate_barracks(wagon_data)

func _clear_content() -> void:
    for child in content_container.get_children():
        child.queue_free()

func _populate_barracks(wagon_data: Dictionary) -> void:
    var unit_ids: Array = wagon_data.get("unit_ids", [])
    for unit_id in unit_ids:
        var unit_data: Dictionary = GameState.get_unit(unit_id)
        if unit_data.is_empty():
            continue
        _add_unit_slot(unit_data)

func _add_unit_slot(unit_data: Dictionary) -> void:
    var unit_id: String = unit_data.get("id", "")
    var unit_type: String = unit_data.get("type", "")

    var btn := Button.new()
    btn.custom_minimum_size = Vector2(40, 40)
    btn.tooltip_text = "HP: %s/%s  XP: %s" % [
        unit_data.get("hp", "?"),
        unit_data.get("max_hp", "?"),
        unit_data.get("experience", 0)
    ]

    var portrait_rect := TextureRect.new()
    portrait_rect.texture = SOLDIER_PORTRAIT
    portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    portrait_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    portrait_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    btn.add_child(portrait_rect)

    btn.pressed.connect(func(): unit_deploy_requested.emit(unit_id, unit_type))
    content_container.add_child(btn)
