extends Unit

@onready var torso_sprite: AnimatedSprite2D = $Parts/Torso
@onready var legs_sprite: AnimatedSprite2D = $Parts/Legs
@onready var left_arm_sprite: AnimatedSprite2D = $Parts/LeftArmFree
@onready var right_arm_sprite: AnimatedSprite2D = $Parts/RightArmWeapon
@onready var weapon_sprite: AnimatedSprite2D = $Parts/Weapon
@onready var dead_part_sprite: AnimatedSprite2D = $Parts/Dead


@onready var render_order = {
    "N": [weapon_sprite, left_arm_sprite, legs_sprite, torso_sprite, right_arm_sprite],
    "S": [torso_sprite, legs_sprite, right_arm_sprite, left_arm_sprite, weapon_sprite],
    
    "NE": [left_arm_sprite, legs_sprite, torso_sprite, weapon_sprite, right_arm_sprite],
    "E": [left_arm_sprite, legs_sprite, torso_sprite, weapon_sprite, right_arm_sprite],
    "SE": [left_arm_sprite, legs_sprite, torso_sprite, weapon_sprite, right_arm_sprite],
    
    "SW": [right_arm_sprite, legs_sprite, torso_sprite, left_arm_sprite, weapon_sprite],
    "W": [right_arm_sprite, weapon_sprite, legs_sprite, torso_sprite, left_arm_sprite],
    "NW": [right_arm_sprite, weapon_sprite, legs_sprite, torso_sprite, left_arm_sprite]
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
    "N": Vector2i(8, -6),
    "NE": Vector2i(10, -3),
    "E": Vector2i(7, 0),
    "SE": Vector2i(4, 2),
    "S": Vector2i(-9, 0),
    "SW": Vector2i(-11, -4),
    "W": Vector2i(-7, -7),
    "NW": Vector2i(-3, -9),
}

var current_animation := ""
var is_animation_playing := false
var is_crouching := false


func toggle_crouch():
    # print("TOGGLE CROUCH")
    is_crouching = not is_crouching
    play_animation(get_current_action(), orientation)

func set_weapon_type(id: String):
    var frames_dict = SoldierAtlasLoader.get_weapon_type(id)
    weapon_sprite.sprite_frames = frames_dict["weapon"]
    #print("Weapon: %s" % weapon.sprite_frames.get_animation_names())

func set_soldier_type(id: String):
    #print("Setting soldier type to %s" % id)
    var frames_dict = SoldierAtlasLoader.get_soldier_type(id)
    #print("FramesDict:", frames_dict["dead_part"])
    torso_sprite.sprite_frames = frames_dict["torso"]
    legs_sprite.sprite_frames = frames_dict["legs"]
    left_arm_sprite.sprite_frames = frames_dict["left_arm"]
    right_arm_sprite.sprite_frames = frames_dict["right_arm"]
    dead_part_sprite.sprite_frames = frames_dict["dead_part"]

    var animation_name = "%s_%s" % ["IdleState", orientation]
    play_animation("IdleState", orientation)

    #print("Torso: %s" % torso.sprite_frames.get_animation_names())
    #print("Legs: %s" % legs.sprite_frames.get_animation_names())
    #print("Left arm: %s" % left_arm.sprite_frames.get_animation_names())
    #print("Right arm: %s" % right_arm.sprite_frames.get_animation_names())

# Set orientation calls play animation
func set_orientation(new_orientation: String):
    # print("Setting orientation to %s" % new_orientation)
    orientation = new_orientation
    # set the part z-indexes in the correct order
    for i in range(5):
        var part = render_order[new_orientation][i]
        part.z_index = i
    
    play_animation(get_current_action(), new_orientation)
    unit_manager.on_unit_orientation_changed(self, new_orientation)
    queue_redraw()

func play_animation(state_: String, orientation_: String):
    if state_ == "DeadState":
        # print("playing animation dead, ", dead_part_sprite)
        dead_part_sprite.play("DeadState_default")
        return


    var animation_name = "%s_%s" % [state_, orientation_]
    
    #if is_animation_playing and animation_name == current_animation: # If we are already playing the animation do nothing
    #    return
    
    #print("Play animation %s" % animation_name)
    current_animation = animation_name
    is_animation_playing = true

    torso_sprite.play(animation_name)
    if is_crouching:
        legs_sprite.play("CrouchState_" + orientation_)
    else:
        legs_sprite.play(animation_name)
    left_arm_sprite.play(animation_name)
    right_arm_sprite.play(animation_name)
    if state_ == "AimState":
        weapon_sprite.offset = weapon_aiming_offsets[orientation_]
    else:
        weapon_sprite.offset = Vector2(0, 0)
    #print("Play animation name: %s" % animation_name)
    
    weapon_sprite.play(animation_name)
    #else:
    #    var weapon_animation_name = "%s_%s" % [state_, ori_to_weapon_holding_ori[orientation_]]
    #    weapon.play(weapon_animation_name)

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
