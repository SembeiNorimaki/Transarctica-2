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

func set_weapon_type(weapon_type: String):
    var parts = WeaponDatabase.get_weapon_data(weapon_type).parts
    weapon_sprite.sprite_frames = parts["weapon"]
    play_animation("IdleState", orientation)

# Sets the unit to a specific type: eg: liquidator, pioneer, etc.
func set_soldier_type(unit_type: String):
    view_range = UnitDatabase.get_unit_data(unit_type).view_range
    view_angle = UnitDatabase.get_unit_data(unit_type).view_angle

    var parts = UnitDatabase.get_unit_data(unit_type).parts
    torso_sprite.sprite_frames = parts["torso"]
    legs_sprite.sprite_frames = parts["legs"]
    left_arm_sprite.sprite_frames = parts["left_arm"]
    right_arm_sprite.sprite_frames = parts["right_arm"]
    dead_part_sprite.sprite_frames = parts["dead_part"]

    # TODO: Should probably not be here
    play_animation("IdleState", orientation)

# Set orientation calls play animation
func set_orientation(new_orientation: String):
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
