extends CanvasLayer

@onready var title_image = $Container/VBoxContainer/TitleImage
@onready var title_label = $Container/VBoxContainer/TitleLabel
@onready var available_label = $Container/VBoxContainer/AvailableLabel
@onready var price_label = $Container/VBoxContainer/PriceLabel
@onready var train_space_label = $Container/VBoxContainer/TrainSpaceLabel
@onready var button1 = $Container/VBoxContainer/Button1
@onready var button2 = $Container/VBoxContainer/Button2


var resource_name: String = ""
var available: int = 0
var price: int = 0
var train_space: int = 0

signal on_button_clicked(buttonIdx: int)

func initialize(data):
    # print("initializing trademenu with data %s" % data)
    resource_name = data.name
    available = data.available
    price = data.price
    train_space = data.train_space

    update_labels()

func get_info():
    return {
        "resource_name": resource_name,
        "available": available,
        "price": price,
        "train_space": train_space
    }

func update_resource(resource_, available_, price_, train_space_):
    resource_name = resource_
    available = available_
    price = price_
    train_space = train_space_

    update_labels()

func show_buy_mode(resource_info: Dictionary):
    visible = true
    title_label.text = resource_info.resource_name
    available_label.text = "Available: %s" % resource_info.qty
    price_label.text = "Price: %s" % resource_info.buy_price
    train_space_label.text = "Train space: 0"
    button1.text = "Buy 1"
    
func show_sell_mode(resource_info: Dictionary):
    visible = true
    title_label.text = resource_info.resource_name
    available_label.text = "Available: %s" % resource_info.qty
    price_label.text = "Price: %s" % resource_info.sell_price
    train_space_label.text = "Train space: %s" % resource_info.train_space
    button1.text = "Sell 1"


func update_labels():
    title_label.text = resource_name
    available_label.text = "Available: %s" % available
    price_label.text = "Price: %s" % price
    train_space_label.text = "Train space: %s" % train_space


func _on_button_pressed() -> void:
    emit_signal("on_button_clicked", 1)


func _on_button_2_pressed() -> void:
    emit_signal("on_button_clicked", 2)
