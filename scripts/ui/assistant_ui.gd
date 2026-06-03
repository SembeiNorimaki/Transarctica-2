extends CanvasLayer

@export var portrait_texture: Texture2D = preload("res://assets/sprites/hud/comrad_face.png")

@onready var panel_container = $PanelContainer
@onready var portrait_rect = $PanelContainer/MarginContainer/HBoxContainer/PortraitRect
@onready var text_label = $PanelContainer/MarginContainer/HBoxContainer/TextLabel
@onready var accept_btn = $PanelContainer/MarginContainer/HBoxContainer/ButtonContainer/AcceptBtn
@onready var cancel_btn = $PanelContainer/MarginContainer/HBoxContainer/ButtonContainer/CancelBtn

var _current_callback: Callable

func _ready() -> void:
	portrait_rect.texture = portrait_texture
	accept_btn.pressed.connect(_on_accept_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	hide_dialog()

func show_message(text: String) -> void:
	text_label.text = text
	accept_btn.text = "Close"
	cancel_btn.hide()
	_current_callback = Callable()
	panel_container.show()

func ask_confirmation(text: String, callback: Callable) -> void:
	text_label.text = text
	accept_btn.text = "Accept"
	cancel_btn.show()
	_current_callback = callback
	panel_container.show()

func hide_dialog() -> void:
	panel_container.hide()

func _on_accept_pressed() -> void:
	if _current_callback.is_valid():
		_current_callback.call()
	hide_dialog()

func _on_cancel_pressed() -> void:
	hide_dialog()
