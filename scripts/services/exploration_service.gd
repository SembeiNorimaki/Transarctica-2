extends Node
class_name ExplorationService

var grid_service: GridService
var exploration_layer: TileMapLayer

func _ready() -> void: pass

func reveal_from_unit():
    pass

func _on_unit_orientation_changed(unit: Unit, new_orientation: String) -> void:
    grid_service.get_tiles_in_vision_cone(unit.current_tile, new_orientation, unit.view_angle, unit.view_range)