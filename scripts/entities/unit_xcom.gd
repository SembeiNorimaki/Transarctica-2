extends Node2D

@onready var torso: AnimatedSprite2D = $Parts/Torso
@onready var legs: AnimatedSprite2D = $Parts/Legs
@onready var left_arm: AnimatedSprite2D = $Parts/LeftArmFree
@onready var right_arm: AnimatedSprite2D = $Parts/RightArmWeapon
@onready var weapon: AnimatedSprite2D = $Parts/Weapon


var render_parts = {
	"torso": torso,
	"legs": legs,
	"left_arm": left_arm,
	"right_arm": right_arm,
	"weapon": weapon
}

@onready var render_order = {
	"N": [weapon, left_arm, right_arm, legs, torso],
	"S": [torso, legs, right_arm, left_arm, weapon],
	
	"NE": [left_arm, torso, legs, weapon, right_arm],
	"E":  [left_arm, torso, legs, weapon, right_arm],
	"SE": [left_arm, torso, legs, weapon, right_arm],
	
	"SW": [right_arm, weapon, torso, legs, left_arm],
	"W":  [right_arm, weapon, torso, legs, left_arm],
	"NW": [right_arm, weapon, torso, legs, left_arm]	
}

func _process(delta):
	if Input.is_key_pressed(KEY_Q):
		play_orientation("NW")
	elif Input.is_key_pressed(KEY_W):
		play_orientation("N")
	elif Input.is_key_pressed(KEY_E):
		play_orientation("NE")
	elif Input.is_key_pressed(KEY_A):
		play_orientation("W")
	elif Input.is_key_pressed(KEY_S):
		pass
		#torso.play("S")
	elif Input.is_key_pressed(KEY_D):
		play_orientation("E")
	elif Input.is_key_pressed(KEY_Z):
		play_orientation("SW")
	elif Input.is_key_pressed(KEY_X):
		play_orientation("S")
	elif Input.is_key_pressed(KEY_C):
		play_orientation("SE")

func play_orientation(ori: String):
	for i in range(5):
		var part = render_order[ori][i]
		part.z_index = i

	torso.play(ori)
	legs.play(ori)
	left_arm.play(ori)
	right_arm.play(ori)
	weapon.play(ori)
