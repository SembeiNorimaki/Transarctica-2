extends Node


var unit_cache = {}

var unit_atlas_loader = UnitAtlasLoader.new()
var unit_scene = preload("res://scenes/entities/units/unit_xcom2.tscn")

#region API methods
func get_unit_data(id: String):
    return unit_cache[id]

func get_unit_type_from_atlas_coords(atlas_coords):
    for unit_type in unit_cache.keys():
        if unit_cache[unit_type].atlas_placeholder_x == atlas_coords.x:
            return unit_type
    return null
            
func get_owner_id_from_atlas_coords(atlas_coords):
    if atlas_coords.y == 0:
        return "Player"
    return "Enemy"

func get_footprint(unit_type_: String):
    return unit_cache[unit_type_].footprint

func get_scene(unit_type_: String):
    return unit_scene
    #unit_cache[unit_type_].scene_file
    
#endregion

func _ready():
    _load_units()


func _load_units():
    var file = FileAccess.open("res://data/unit_types.json", FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    for unit_name in data.keys():
        var u_data = data[unit_name]
        unit_cache[unit_name] = u_data

        var atlas = load(u_data.atlas_file)
        var parts = unit_atlas_loader.load_unit_type(unit_name, atlas)
        print("atlas: ", atlas, "parts: ", parts)

        unit_cache[unit_name].parts = parts
