extends Unit

@onready var torso: AnimatedSprite2D = $Parts/Torso
@onready var legs: AnimatedSprite2D = $Parts/Legs
@onready var left_arm: AnimatedSprite2D = $Parts/LeftArmFree
@onready var right_arm: AnimatedSprite2D = $Parts/RightArmWeapon
@onready var weapon: AnimatedSprite2D = $Parts/Weapon
@onready var dead_part: AnimatedSprite2D = $Parts/Dead


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

var ori_to_weapon_holding_ori = {
	"N": "W",
	"NE": "NW",
	"E": "N",
	"SE": "NE",
	"S": "E",
	"SW": "SE",
	"W": "S",
	"NW": "SW"
}

var weapon_aiming_offsets = {
	"N":  Vector2i(8,-6),
	"NE": Vector2i(10,-3),
	"E":  Vector2i(7,0),
	"SE": Vector2i(4,2),
	"S":  Vector2i(-9,0),
	"SW": Vector2i(-11,-4),
	"W":  Vector2i(-7,-7),
	"NW": Vector2i(-3,-9), 
}

@onready var unit_ai = $UnitAI

var current_animation := ""
var is_animation_playing := false
var is_crouching := false


func toggle_crouch():
	print("TOGGLE CROUCH")
	is_crouching = not is_crouching
	play_animation(get_current_action(), orientation)

func set_weapon_type(id: String):
	var frames_dict = SoldierAtlasLoader.get_weapon_type(id)
	weapon.sprite_frames = frames_dict["weapon"]
	#print("Weapon: %s" % weapon.sprite_frames.get_animation_names())

func set_soldier_type(id: String):
	#print("Setting soldier type to %s" % id)
	var frames_dict = SoldierAtlasLoader.get_soldier_type(id)
	#print("FramesDict:", frames_dict["dead_part"])
	torso.sprite_frames = frames_dict["torso"]
	legs.sprite_frames = frames_dict["legs"]
	left_arm.sprite_frames = frames_dict["left_arm"]
	right_arm.sprite_frames = frames_dict["right_arm"]
	dead_part.sprite_frames = frames_dict["dead_part"]

	var animation_name = "%s_%s" % ["IdleState", orientation]
	play_animation("IdleState", orientation)

	#print("Torso: %s" % torso.sprite_frames.get_animation_names())
	#print("Legs: %s" % legs.sprite_frames.get_animation_names())
	#print("Left arm: %s" % left_arm.sprite_frames.get_animation_names())
	#print("Right arm: %s" % right_arm.sprite_frames.get_animation_names())

# Set orientation calls play animation
func set_orientation(new_orientation: String):
	print("Setting orientation to %s" % new_orientation)
	orientation = new_orientation
	# set the part z-indexes in the correct order
	for i in range(5):
		var part = render_order[new_orientation][i]
		part.z_index = i
	
	play_animation(get_current_action(), new_orientation)
	unit_manager.on_unit_orientation_changed(self, new_orientation)
	queue_redraw()

func play_animation(state_: String, orientation_ : String):
	if state_ == "DeadState":
		print("playing animation dead, ", dead_part)
		dead_part.play("DeadState_default")
		return


	var animation_name = "%s_%s" % [state_, orientation_]
	
	#if is_animation_playing and animation_name == current_animation: # If we are already playing the animation do nothing
	#	return
	
	print("Play animation %s" % animation_name)
	current_animation = animation_name
	is_animation_playing = true

	torso.play(animation_name)
	if is_crouching:
		legs.play("CrouchState_" + orientation_)
	else:
		legs.play(animation_name)
	left_arm.play(animation_name)
	right_arm.play(animation_name)
	if state_ == "AimState":
		weapon.offset = weapon_aiming_offsets[orientation_]
	else:
		weapon.offset = Vector2(0,0)
	weapon.play(animation_name)
	#else:
	#	var weapon_animation_name = "%s_%s" % [state_, ori_to_weapon_holding_ori[orientation_]]
	#	weapon.play(weapon_animation_name)

func move_to_tile(tile: Vector2i):
	print("Unit %s instructed to move to tile %s" % [id, tile])
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
