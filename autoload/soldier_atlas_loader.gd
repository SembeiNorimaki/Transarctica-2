extends Node


const UNIT_ATLAS_LAYOUT = preload("res://unitXcomLayout.gd")
const WEAPON_ATLAS_LAYOUT = preload("res://weaponXcomLayout.gd")

var cache = {}
var weapon_cache = {}

func _ready():
	_load_soldiers()
	_load_weapons()

func get_soldier_type(id: String):
	return cache[id]
func get_weapon_type(id: String):
	return weapon_cache[id]

func _load_soldiers():
	var tritanium_atlas := load("res://assets/sprites/HEAVY_TRITANIUM_SUIT.png")
	var dagon_atlas := load("res://assets/sprites/DISCIPLE_OF_DAGON.png")
	load_soldier_type("HeavyTritaniumSuit", tritanium_atlas)
	load_soldier_type("Dagon", dagon_atlas)

func _load_weapons():
	var m60_atlas := load("res://assets/sprites/handob_M60.png")
	load_weapon_type("M60", m60_atlas)
	
func load_weapon_type(id: String, atlas: Texture2D):
	if weapon_cache.has(id):
		return weapon_cache[id]
	var parts := {
		"weapon": SpriteFrames.new()
	}
	for part in parts.keys():
		_build_weapon_frames(parts[part], atlas, part)

	weapon_cache[id] = parts
	return parts

func _build_weapon_frames(frames: SpriteFrames, atlas: Texture2D, part: String):
	var layout = WEAPON_ATLAS_LAYOUT.atlas2[part]
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
	# print("cache: %s" % cache)
	return parts

func _build_frames(frames: SpriteFrames, atlas: Texture2D, part: String):
	#print("Build frames for %s" % part)
	var layout = UNIT_ATLAS_LAYOUT.atlas2[part]

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
