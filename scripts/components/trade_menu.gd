extends CanvasLayer

@onready var title_image = $Container/VBoxContainer/TitleImage
@onready var title_label = $Container/VBoxContainer/TitleLabel
@onready var available_label = $Container/VBoxContainer/AvailableLabel
@onready var price_label = $Container/VBoxContainer/PriceLabel
@onready var train_space_label = $Container/VBoxContainer/TrainSpaceLabel

var resource_name: String = ""
var available: int = 0
var price: int = 0
var train_space: int = 0


func initialize(data):
	print("initializing trademenu with data %s" % data)
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

func update_labels():
	title_label.text = resource_name
	available_label.text = "Available: %s" % available
	price_label.text = "Price: %s" % price
	train_space_label.text = "Train space: %s" % train_space
