extends Node2D
class_name Crate

@onready var sprite_inwagon = $SpriteInWagon
@onready var sprite_inground = $SpriteInGround
var current_sprite: Sprite2D
var qty := 0


# "InWagon", "InGround"
func set_mode(mode_: String):
	if mode_ == "InWagon":
		current_sprite = sprite_inwagon
		sprite_inwagon.visible = true
		sprite_inground.visible = false
	else:
		current_sprite = sprite_inground
		sprite_inwagon.visible = false
		sprite_inground.visible = true

func set_qty(qty_: int):
	print("Setting crate qty to %s" % qty_)
	qty = qty_
	if qty_ == 0:
		current_sprite.visible = false
	elif qty_ > 12:
		current_sprite.frame = 11
		current_sprite.visible = true
	else:
		current_sprite.frame = qty_ - 1
		current_sprite.visible = true
	
