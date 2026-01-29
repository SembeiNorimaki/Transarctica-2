extends Node

# This hasn't been tested yet

var cache = {}

func _ready():
    _load_soldiers()

func _load_soldiers():
    var tex := load("res://sprites/%s.png" % id)

func load_soldier_type(id: String, atlas: Texture2D):
    if cache.has(id):
        return cache[id]
    
    var parts := {
        "legs": SpriteFrames.new(),
        "torso": SpriteFrames.new(),
        "left_arm": SpriteFrames.new(),
        "right_arm": SpriteFrames.new()
    }

    for part in parts.keys():
        _build_frames(parts[part], atlas, part)

    cache[id] = parts
    return parts

func _build_frames(frames: SpriteFrames, atlas: Texture2D, part: String):
    var layout := ATLAS_LAYOUT[part]

    for dir in layout.keys():
        frames.add_animation(dir)
        frames.set_animation_speed(dir, 8)

        var start := layout[dir[
            for i in range(8):
                var region := Rect2(
                    Vector2((start.x + i) * FRAME_W, start.y * FRAME_H),
                    Vector2(FRAME_W, FRAME_H)
                )
                var subtex := atlas.get_region(region)
                frames.add_frame(dir, subtex)
        ]]
