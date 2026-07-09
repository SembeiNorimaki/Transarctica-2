extends Control

@onready var weapon_texture: TextureRect = $HBoxContainer2/Weapon
@onready var portrait_texture: TextureRect = $HBoxContainer/Portrait

func setup(params: Dictionary):
    set_portrait(params.unit_type)
    set_weapon(params.weapon_type)

func set_portrait(unit_type_: String):
    var unit_image = UnitDatabase.get_unit_data(unit_type_).portrait
    portrait_texture.texture = unit_image

func set_weapon(weapon_type_: String):
    var weapon_image = WeaponDatabase.get_weapon_data(weapon_type_).bigob
    weapon_texture.texture = weapon_image
