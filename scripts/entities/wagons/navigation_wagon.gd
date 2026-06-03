extends Node2D
class_name NavigationWagon

# Dependencies
var grid_service: GridService


signal tile_changed(wagon, old_tile: Vector2i, new_tile: Vector2i)

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var attachments = {
	"front": $Attachments/front, 
	"back": $Attachments/back
}

var current_tile := Vector2i(-1, -1)
var orientation := ""
var cargo := ""
var cargo_amount := "Empty"
var heading = Vector2(1.0, 0.0)
var speed := 0.0
var wagon_type := ""


# offsets for the front and back collision shapes
const ATTACHMENTS_OFFSETS = {
	"N":  { "front": Vector2(10, -11), "back": Vector2(-18,  6) },
	"S":  { "front": Vector2(-18, 6), "back": Vector2(10, -11) },

	"E":  { "front": Vector2(17, 6), "back": Vector2(-10, -12) },
	"W":  { "front": Vector2(-10, -12), "back": Vector2(17, 6) },
	
	"NW": { "front": Vector2(0, -24), "back": Vector2(0, 13) },
	"SE": { "front": Vector2(0, 13), "back": Vector2(0, -24) },

	"NE": { "front": Vector2(24, 0), "back": Vector2(-25, 0) },
	"SW": { "front": Vector2(-25, 0), "back": Vector2(-24, 0) }
}

const ORIENTATIONS = ["SE", "S", "SW", "W", "NW", "N", "NE", "E"]

#region initialization
func _ready() -> void:
	pass

func initialize(wagon_type: String) -> void:
	set_wagon_type(wagon_type)
	
func set_wagon_type(wagon_type_: String) -> void:
	wagon_type = wagon_type_
	var atlas_path = "res://assets/sprites/wagons/navigation/nav_%s.png" % wagon_type
	var atlas: Texture2D = load(atlas_path)

	var orientations = WagonTypes.TYPES[wagon_type].navigation_atlas_orientations
	var cargos = WagonTypes.TYPES[wagon_type].navigation_atlas_cargo
	var default_cargo = WagonTypes.TYPES[wagon_type].default_cargo
	
	cargo = default_cargo
	print("Setting cargo to %s" % cargo)
	
	if atlas == null:
		push_error("Missing atlas for wagon type: %s" % wagon_type)
		return
	_create_animations_from_atlas(atlas, orientations, cargos)

func _create_animations_from_atlas(atlas: Texture2D, orientations: Array, cargos: Array) -> void:
	var frames := SpriteFrames.new()

	var frame_width = atlas.get_width() / orientations.size()
	var frame_height = atlas.get_height() / cargos.size()

	for j in cargos.size():
		var tokens = cargos[j].split("_")
		var cargo_name = tokens[0]      # Wood, Copper, Iron....
		var cargo_amount = tokens[1]    # either Half or Full
		for i in orientations.size():
			var ori_name = orientations[i]
			var frame_name = "%s_%s_%s" % [ori_name, cargo_name, cargo_amount]   # Ex:  S_Iron_Full, NE_Wood_Half
			#print("Creating animation %s" % frame_name)
			frames.add_animation(frame_name)
			frames.set_animation_speed(frame_name, 1) # static frame
			var region = Rect2(
				Vector2(i * frame_width, j * frame_height),
				Vector2(frame_width, frame_height)
			)
			var atlas_tex := AtlasTexture.new()
			atlas_tex.atlas = atlas
			atlas_tex.region = region
			frames.add_frame(frame_name, atlas_tex)

	sprite.sprite_frames = frames

#endregion

func set_pos(new_pos: Vector2):
	position = new_pos
	current_tile = grid_service.world_to_tile(new_pos)

func set_orientation(new_ori: String):
	print("Setting wagon orientation to %s" % new_ori)
	if orientation != new_ori:
		orientation = new_ori
		# change the position of the attachments
		attachments.front.position = ATTACHMENTS_OFFSETS[new_ori].front
		attachments.back.position = ATTACHMENTS_OFFSETS[new_ori].back
		update_animation()

#region attachments
func enable_front_attachment(enabled: bool):
	attachments.front.disabled = not enabled

func enable_back_attachment(enabled: bool):
	attachments.back.disabled = not enabled

func disable_all_attachments():
	attachments.front.disabled = true
	attachments.back.disabled = true
#endregion

func set_heading(new_heading: Vector2):
	heading = new_heading

func update_animation():
	var animation_name = "%s_%s_%s" % [orientation, cargo_amount, cargo]
	print("%s: Animation name: %s" % [wagon_type, animation_name])
	sprite.set_animation(animation_name)
	sprite.play(animation_name)

func _process(delta):
	_move(delta)
	_check_tile_change()

func _move(delta: float):
	position += heading * speed * delta

func _check_tile_change():
	var new_tile = grid_service.world_to_tile(position)
	if current_tile != new_tile:
		emit_signal("tile_changed", self, current_tile, new_tile)
		current_tile = new_tile
