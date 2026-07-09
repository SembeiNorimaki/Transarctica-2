extends Node
class_name UnitAtlasLoader

const UNIT_ATLAS_LAYOUT = preload("res://data/definitions/unitXcomLayout.gd")

func load_unit_type(id: String, atlas: Texture2D) -> Dictionary:
    print("load unit type: ", id, " with atlas: ", atlas)
    var parts := {
        "legs": SpriteFrames.new(),
        "torso": SpriteFrames.new(),
        "left_arm": SpriteFrames.new(),
        "right_arm": SpriteFrames.new(),
        "dead_part": SpriteFrames.new()
    }

    for part in parts.keys():
        _build_unit_frames(parts[part], atlas, part)
    
    return parts

func _build_unit_frames(frames: SpriteFrames, atlas: Texture2D, part: String):
    var layout = UNIT_ATLAS_LAYOUT.atlas[part]
    for action in layout.keys():
        for dir in layout[action].keys():
            var animation_name := "%s_%s" % [action, dir]
            frames.add_animation(animation_name)
            frames.set_animation_speed(animation_name, 8)
            
            for tile in layout[action][dir]:
                var start = Vector2i(tile.x * UNIT_ATLAS_LAYOUT.FRAME_W, tile.y * UNIT_ATLAS_LAYOUT.FRAME_H)
                var region := Rect2(
                    Vector2(start.x, start.y),
                    Vector2(UNIT_ATLAS_LAYOUT.FRAME_W, UNIT_ATLAS_LAYOUT.FRAME_H)
                )
                var subtex := AtlasTexture.new()
                subtex.atlas = atlas
                subtex.region = region
                frames.add_frame(animation_name, subtex)

func _load_unit_portraits(atlas: Texture2D):
    pass
