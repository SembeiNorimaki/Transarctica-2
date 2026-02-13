extends Unit

@onready var torso: AnimatedSprite2D = $Parts/Torso
@onready var legs: AnimatedSprite2D = $Parts/Legs
@onready var left_arm: AnimatedSprite2D = $Parts/LeftArmFree
@onready var right_arm: AnimatedSprite2D = $Parts/RightArmWeapon
@onready var weapon: AnimatedSprite2D = $Parts/Weapon

@onready var render_order = {
	"N": [weapon, left_arm, legs, torso, right_arm],
	"S": [torso, legs, right_arm, left_arm, weapon],
	
	"NE": [left_arm, legs, torso, weapon, right_arm],
	"E": [left_arm, legs, torso, weapon, right_arm],
	"SE": [left_arm, legs, torso, weapon, right_arm],
	
	"SW": [right_arm, legs, torso, left_arm, weapon],
	"W": [right_arm, weapon, legs, torso, left_arm],
	"NW": [right_arm, weapon, legs, torso, left_arm]
}

var current_animation := ""
var is_animation_playing := false


func set_weapon_type(id: String):
	var frames_dict = SoldierAtlasLoader.get_weapon_type(id)
	weapon.sprite_frames = frames_dict["weapon"]
	print("Weapon: %s" % weapon.sprite_frames.get_animation_names())

func set_soldier_type(id: String):
	#print("Setting soldier type to %s" % id)
	var frames_dict = SoldierAtlasLoader.get_soldier_type(id)
	torso.sprite_frames = frames_dict["torso"]
	legs.sprite_frames = frames_dict["legs"]
	left_arm.sprite_frames = frames_dict["left_arm"]
	right_arm.sprite_frames = frames_dict["right_arm"]

	print("Torso: %s" % torso.sprite_frames.get_animation_names())
	print("Legs: %s" % legs.sprite_frames.get_animation_names())
	print("Left arm: %s" % left_arm.sprite_frames.get_animation_names())
	print("Right arm: %s" % right_arm.sprite_frames.get_animation_names())

# Set orientation calls play animation
func set_orientation(new_orientation: String):
	orientation = new_orientation
	# set the part z-indexes in the correct order
	for i in range(5):
		var part = render_order[new_orientation][i]
		part.z_index = i
	
	var animation_name = "%s_%s" % [get_current_action(), new_orientation]
	print("Orientation changed to %s, new animation_name: %s" % [new_orientation, animation_name])
	play_animation(animation_name)
	unit_manager.on_unit_orientation_changed(self, new_orientation)
	queue_redraw()

func play_animation(animation_name: String):
	if is_animation_playing and animation_name == current_animation: # If we are already playing the animation do nothing
		return
	
	print("Play animation %s" % animation_name)
	current_animation = animation_name
	is_animation_playing = true

	torso.play(animation_name)
	legs.play(animation_name)
	left_arm.play(animation_name)
	right_arm.play(animation_name)
	weapon.play(animation_name)

func move_to_tile(tile: Vector2i):
	#print("Unit %s instructed to move to tile %s" % [id, tile])
	target_tile = tile
	# calculate new orientation
	var delta = target_tile - current_tile
	var new_ori = grid_service.get_orientation(current_tile, target_tile)
	if new_ori != orientation:
		set_orientation(new_ori)
	#set_state("MoveState", {"unit": self})
	#play_animation("MoveState_%s" % new_ori)
	#
	#set_process(true)
