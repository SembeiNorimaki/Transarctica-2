extends HBoxContainer
class_name BarracksPanel

const SOLDIER_PORTRAIT: Texture2D = preload("res://assets/sprites/soldier.png")

@onready var units_container: HBoxContainer = $UnitsContainer

var _wagon_id: int = -1
var _wagon_manager: WagonManager = null

func setup(wagon_data: Dictionary, wagon_id: int, wagon_manager: WagonManager) -> void:
    _wagon_id = wagon_id
    _wagon_manager = wagon_manager

    var unit_ids: Array = wagon_data.get("unit_ids", [])
    for unit_id in unit_ids:
        var unit_data: Dictionary = GameState.get_unit(unit_id)
        if unit_data.is_empty():
            continue
        _add_unit_slot(unit_data)

func _add_unit_slot(unit_data: Dictionary) -> void:
    var unit_id: String = unit_data.get("id", "")

    var btn := Button.new()
    btn.custom_minimum_size = Vector2(40, 40)
    btn.tooltip_text = "HP: %s/%s  XP: %s — Click to deploy" % [
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

    btn.pressed.connect(func(): _wagon_manager.request_unit_unloading(_wagon_id, unit_id))
    units_container.add_child(btn)
