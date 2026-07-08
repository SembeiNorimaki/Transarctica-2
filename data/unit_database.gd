extends Node
class_name UnitDatabase

var unit_cache = {}

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
    return get(unit_cache[unit_type_].footprint, null)

func get_scene(unit_type_: String):
    pass
    
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
        var parts = soldier_atlas_loader.load_unit_type(unit_name, atlas)
        unit_cache[unit_name].parts = parts

        # needs also:   scene and footprint
