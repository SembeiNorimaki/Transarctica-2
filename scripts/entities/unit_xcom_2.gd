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

func set_orientation(new_orientation: String):
    orientation = new_orientation
    torso.set_animation(new_orientation)
    legs.set_animation(new_orientation)
    left_arm.set_animation(new_orientation)
    right_arm.set_animation(new_orientation)
    weapon.set_animation(new_orientation)
    unit_manager.on_unit_orientation_changed(self, new_orientation)
    queue_redraw()

func play_orientation(ori: String):
    for i in range(5):
        var part = render_order[ori][i]
        part.z_index = i

    torso.play(ori)
    legs.play(ori)
    left_arm.play(ori)
    right_arm.play(ori)
    weapon.play(ori)
