extends CanvasLayer

@onready var title_image = $Container/VBoxContainer/TitleImage
@onready var title_label = $Container/VBoxContainer/TitleLabel
@onready var available_label = $Container/VBoxContainer/AvailableLabel
@onready var price_label = $Container/VBoxContainer/PriceLabel
@onready var train_space_label = $Container/VBoxContainer/TrainSpaceLabel

func initialize(data):
	title_label.text = data.name
	available_label.text = "Available: %s"%data.available
	price_label.text = "Price: %s" % data.price
	train_space_label.text = "Train space: %s" % data.train_space
