extends Node
class_name WeaponDatabase

var weapon_cache = {}

#region API methods
func get_weapon_data(id: String):
    return weapon_cache[id]
    
#endregion

func _ready():
    _load_weapons()


func _load_weapons():
    var file = FileAccess.open("res://data/weapon_types.json", FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    for w_name in data.keys():
        var w_data = data[w_name]
        weapon_cache[w_name] = w_data

        var atlas = load(w_data.atlas_file)
        var parts = weapon_atlas_loader.load_weapon_type(w_name, atlas)
        weapon_cache[w_name].parts = parts
