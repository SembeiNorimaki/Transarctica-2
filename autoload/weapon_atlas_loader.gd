extends Node
class_name WeaponAtlasLoader

const WEAPON_ATLAS_LAYOUT = preload("res://data/weaponXcomLayout.gd")

func load_weapon_type(id: String, atlas: Texture2D) -> Dictionary:
    var parts := {
        "weapon": SpriteFrames.new()
    }

    for part in parts.keys():
        _build_weapon_frames(parts[part], atlas, part)

    return parts

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
