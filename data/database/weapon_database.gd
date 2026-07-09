extends Node

const weapon_definitions_file = "res://data/definitions/weapon_types.json"

# this is an example of weapon_cache structure.
# the dict is cleared at _ready()
var weapon_cache = {
    "parts": {},
    "bigob": null, # image
    "damage": 10,
    "accuracy": 80,
    "range": 5,
    "ammo": 3,
    "ap_cost": 20
}

var weapon_atlas_loader = WeaponAtlasLoader.new()

#region API methods
func get_weapon_data(id: String):
    return weapon_cache[id]
    
#endregion

func _ready():
    _load_weapons()


func _load_weapons():
    var file = FileAccess.open(weapon_definitions_file, FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    weapon_cache.clear()
    for w_name in data.keys():
        var w_data = data[w_name]
        weapon_cache[w_name] = w_data

        var atlas = load(w_data.atlas_file)
        
        var parts = weapon_atlas_loader.load_weapon_type(w_name, atlas)
        weapon_cache[w_name].parts = parts

        var bigob = load(w_data.bigob_file)
        weapon_cache[w_name].bigob = bigob
