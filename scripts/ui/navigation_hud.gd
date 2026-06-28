extends Control

signal findengine_pressed
signal camera_lock_to_engine_toggle
signal save_pressed
signal minimap_pressed

var double_click_time = 0.5
var double_click_timer = double_click_time
var double_click_possible = false ## True between first and second click
var engine_camera_lock = false ## True will lock camera pos to the train engine

func _physics_process(delta: float) -> void:
    if double_click_possible:
        double_click_timer -= delta
    if double_click_timer <= 0:
        double_click_possible = false
    $CanvasLayer/DebugLabel.text = "Camera locked on engine: " + str(engine_camera_lock)

func update_gold(new_value):
    $CanvasLayer/HBoxContainer/Container5/Gold/Label.text = str(new_value)

func update_fuel(new_value):
    $CanvasLayer/HBoxContainer/Container6/Fuel/Label.text = str(new_value)

func update_speed(new_value):
    $CanvasLayer/HBoxContainer/Container7/Frame/Label.text = str(new_value)

func update_time(new_value):
    $TimeLabel.text = str(new_value)

func _on_button_findengine_pressed() -> void:
    if double_click_possible == false:
        double_click_possible = true
        double_click_timer = double_click_time
    else:
        emit_signal("camera_lock_to_engine_toggle")
        if engine_camera_lock == true:
            engine_camera_lock = false
            $CanvasLayer/HBoxContainer/Container1/LockIcon.visible = false
        else:
            engine_camera_lock = true
            $CanvasLayer/HBoxContainer/Container1/LockIcon.visible = true
    emit_signal("findengine_pressed")

func _on_button_save_pressed() -> void:
    emit_signal("save_pressed")

func _on_button_minimap_pressed() -> void:
    emit_signal("minimap_pressed")
