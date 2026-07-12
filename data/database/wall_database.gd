extends Node

const wall_definitions_file = "res://data/definitions/wall_types.json"

const WALL_LEFT_SCENE = preload("res://scenes/entities/walls/wall_left.tscn")
const WALL_RIGHT_SCENE = preload("res://scenes/entities/walls/wall_right.tscn")
const WALL_FULL_SCENE = preload("res://scenes/entities/walls/wall_full.tscn")

const WALL_LEFT_ATLAS_FILE = "res://assets/tilesets/walls/WallsL.png"
const WALL_RIGHT_ATLAS_FILE = "res://assets/tilesets/walls/WallsR.png"
const WALL_FULL_ATLAS_FILE = "res://assets/tilesets/walls/Walls_Full.png"

const atlas_left = preload(WALL_LEFT_ATLAS_FILE)
const atlas_right = preload(WALL_RIGHT_ATLAS_FILE)

# TODO: this need to go in wall_types
const ATLAS_COORDS_TO_EDGE_TYPE = {
    Vector2i(0, 0): Edge.EdgeType.WALL,
    Vector2i(1, 0): Edge.EdgeType.WINDOW,
    Vector2i(3, 0): Edge.EdgeType.WALL,
    Vector2i(4, 0): Edge.EdgeType.WINDOW
}

var atlas_coords_to_wall_name = {}

var wall_cache = {
    "wall1": {
        "imgs": {
            "left": null,
            "right": null,
            "left_destroyed": null,
            "right_destroyed": null
        },
        "is_destructible": true,
        "wall_type": "WallLow",
        "hp": 10
    }
}

func _ready():
    _load_walls()


func _load_walls():
    var file = FileAccess.open(wall_definitions_file, FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    wall_cache.clear()

    
    for w_name in data.keys():
        var w_data = data[w_name]
        
        wall_cache[w_name] = w_data
        atlas_coords_to_wall_name[Vector2i(w_data.atlas_coords.ok[0], w_data.atlas_coords.ok[1])] = w_name

        var parts = {}
        
        const FRAME_W = 64
        const FRAME_H = 80
         
        var start = Vector2i(w_data.atlas_coords.ok[0] * FRAME_W, w_data.atlas_coords.ok[1] * FRAME_H)
        var region := Rect2(
            Vector2(start.x, start.y),
            Vector2(FRAME_W, FRAME_H)
        )
        var subtex_left := AtlasTexture.new()
        var subtex_right := AtlasTexture.new()
        subtex_left.atlas = atlas_left
        subtex_right.atlas = atlas_right
        subtex_left.region = region
        subtex_right.region = region
        parts.left = subtex_left
        parts.right = subtex_right

        start = Vector2i(w_data.atlas_coords.destroyed[0] * FRAME_W, w_data.atlas_coords.destroyed[1] * FRAME_H)
        region = Rect2(
            Vector2(start.x, start.y),
            Vector2(FRAME_W, FRAME_H)
        )
        subtex_left = AtlasTexture.new()
        subtex_right = AtlasTexture.new()
        subtex_left.atlas = atlas_left
        subtex_right.atlas = atlas_right
        subtex_left.region = region
        subtex_right.region = region
        parts.left_destroyed = subtex_left
        parts.right_destroyed = subtex_right


        wall_cache[w_name].parts = parts

        
func get_image_for_part(wall_name: String, part_name: String) -> Texture:
    return wall_cache[wall_name].parts.get(part_name, null)

func get_wall_name_from_coords(atlas_coords: Vector2i) -> String:
    return atlas_coords_to_wall_name.get(atlas_coords, "")

func get_edge_type(atlas_coords: Vector2i) -> Edge.EdgeType:
    return ATLAS_COORDS_TO_EDGE_TYPE.get(atlas_coords)
