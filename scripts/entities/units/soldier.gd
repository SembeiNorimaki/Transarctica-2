extends Node2D
class_name Soldier

@onready var action_sm: StateMachine = $ActionStateMachine
#@onready var weapon_component: WeaponService
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: HealthBar = $HealthBar
@onready var ap_component: ApComponent = $ApComponent
@onready var unit_ai: UnitAI = $UnitAI

# Dependencies


# Variables
var id: String = ""    

var current_tile := Vector2i(-1, -1)
var orientation := "SE"
var view_angle := 90.0
var view_range := 12

# Signals

# Audios
const SOLDIER_HIT_SFX: AudioStream = preload("res://assets/audio/SoldierHit.wav")
const SOLDIER_DIES_SFX: AudioStream = preload("res://assets/audio/SoldierDies.wav")

func _ready() -> void:
    # Connect signals
    pass

func initialize(id_: String, team_id_: String) -> void:
    set_id(id_)
    set_team(team_id_)
    id_label.text = id
    
