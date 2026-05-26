extends Node2D
class_name NavigationWagon

# Dependencies
var grid_service: GridService


signal tile_changed(wagon, old_tile: Vector2i, new_tile: Vector2i)

@onready var sprite = $Sprite
@onready var attachments = {
	"front": $Attachments/front, 
	"back": $Attachments/back
}

var current_tile := Vector2i(-1, -1)
var orientation := ""
var heading = Vector2(1.0, 0.0)
var speed := 0.0


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

func _ready() -> void:
	pass

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


func enable_front_attachment(enabled: bool):
	attachments.front.disabled = not enabled

func enable_back_attachment(enabled: bool):
	attachments.back.disabled = not enabled

func disable_all_attachments():
	attachments.front.disabled = true
	attachments.back.disabled = true


func set_heading(new_heading: Vector2):
	heading = new_heading

func update_animation():
	sprite.set_animation(orientation)
	sprite.play(orientation)

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
