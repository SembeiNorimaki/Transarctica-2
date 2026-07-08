extends Node

const WEAPON_ATLAS_LAYOUT = preload("res://data/weaponXcomLayout.gd")

var weapon_cache = {}
var weapon_info_cache = {}


func get_weapon_type(id: String):
    return weapon_cache[id]


func get_weapon_info(id: String) -> Dictionary:
    return weapon_info_cache.get(id, {})


func _ready():
    _load_weapons()

func _load_weapons():
    var file = FileAccess.open("res://data/weapon_types.json", FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    for weapon_name in data.keys():
        var w_data = data[weapon_name]
        var atlas = load(w_data.atlas_file)
        _load_weapon_type(weapon_name, atlas)

func _load_weapon_type(id: String, atlas: Texture2D):
    print("Load weapon type %s" % id)
    if weapon_cache.has(id):
        return
    var parts := {
        "weapon": SpriteFrames.new()
    }
    for part in parts.keys():
        _build_weapon_frames(parts[part], atlas, part)

    weapon_cache[id] = parts

func _build_weapon_frames(frames: SpriteFrames, atlas: Texture2D, part: String):
    var layout = WEAPON_ATLAS_LAYOUT.atlas[part]
    for action in layout.keys():
        for dir in layout[action].keys():
            var animation_name := "%s_%s" % [action, dir]
            frames.add_animation(animation_name)
            frames.set_animation_speed(animation_name, 8)

            for tile in layout[action][dir]:
                var start = Vector2i(tile.x * WEAPON_ATLAS_LAYOUT.FRAME_W, tile.y * WEAPON_ATLAS_LAYOUT.FRAME_H)
                var region := Rect2(
                    Vector2(start.x, start.y),
                    Vector2(WEAPON_ATLAS_LAYOUT.FRAME_W, WEAPON_ATLAS_LAYOUT.FRAME_H)
                )
                var subtex := AtlasTexture.new()
                subtex.atlas = atlas
                subtex.region = region
                frames.add_frame(animation_name, subtex)
