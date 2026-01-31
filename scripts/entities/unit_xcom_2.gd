extends Unit

@onready var torso: AnimatedSprite2D = $Parts/Torso
@onready var legs: AnimatedSprite2D = $Parts/Legs
@onready var left_arm: AnimatedSprite2D = $Parts/LeftArmFree
@onready var right_arm: AnimatedSprite2D = $Parts/RightArmWeapon
@onready var weapon: AnimatedSprite2D = $Parts/Weapon

@onready var render_order = {
	"N": [weapon, left_arm, right_arm, legs, torso],
	"S": [torso, legs, right_arm, left_arm, weapon],
	
	"NE": [left_arm, torso, legs, weapon, right_arm],
	"E": [left_arm, torso, legs, weapon, right_arm],
	"SE": [left_arm, torso, legs, weapon, right_arm],
	
	"SW": [right_arm, weapon, torso, legs, left_arm],
	"W": [right_arm, weapon, torso, legs, left_arm],
	"NW": [right_arm, weapon, torso, legs, left_arm]
}


func set_soldier_type(id: String):
	print("Setting soldier type to %s" % id)
	var frames_dict = SoldierAtlasLoader.get_soldier_type(id)
	torso.sprite_frames = frames_dict["torso"]
	legs.sprite_frames = frames_dict["legs"]
	left_arm.sprite_frames = frames_dict["left_arm"]
	right_arm.sprite_frames = frames_dict["right_arm"]

	print("Torso: %s" % torso.sprite_frames.get_animation_names())
	print("Legs: %s" % legs.sprite_frames.get_animation_names())
	print("Left arm: %s" % left_arm.sprite_frames.get_animation_names())
	print("Right arm: %s" % right_arm.sprite_frames.get_animation_names())

func set_orientation(new_orientation: String):
	orientation = new_orientation
	var animation_name = "%s_%s" % [get_current_action(), new_orientation]
	print("Orientation changed to %s, new animation_name: %s" % [new_orientation, animation_name])
	torso.set_animation(animation_name)
	legs.set_animation(animation_name)
	left_arm.set_animation(animation_name)
	right_arm.set_animation(animation_name)
	weapon.set_animation(animation_name)
	unit_manager.on_unit_orientation_changed(self, new_orientation)
	queue_redraw()

func play_orientation(ori: String):
	print("Play orientation %s" % ori)
	for i in range(5):
		var part = render_order[ori][i]
		part.z_index = i

	torso.play(ori)
	legs.play(ori)
	left_arm.play(ori)
	right_arm.play(ori)
	weapon.play(ori)
