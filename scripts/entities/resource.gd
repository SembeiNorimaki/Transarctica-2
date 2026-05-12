extends Node2D

@onready var qty_label = $QtyLabel
@onready var sprite2D = $Sprite2D
var resource_name: String = ""

var resource_name_to_frame = {
	"alcohol":    0,
	"antiques":   1,
	"missiles":   2,
	"bricks":     3,
	"caviar":     4,
	"oil":     	  5,
	"earth": 	  6,
	"coal": 	  7,
	"plants": 	  8,
	"copper": 	  9,
	"dung": 	  10,
	"rails": 	  11,
	"fish": 	  25,
	"rods": 	  13,
	"salt": 	  14,
	"furs": 	  15,
	"gasoline":   16,
	"inspection": 17,
	"gray":       18,
	"meat":       19,
	"wood":       20
}
var frame_to_resource_name = {
	0: "alcohol",
	1: "antiques",
	2: "missiles",
	3: "bricks",
	4: "caviar",
	5: "oil",
	6: "earth",
	7: "coal",
	8: "plants",
	9: "copper",
	10: "dung",
	11: "rails",
	12: "fish",
	13: "rods",
	14: "salt",
	15: "furs",
	16: "gasoline",
	17: "inspection",
	18: "gray",
	19: "meat",
	20: "wood"
}

func _ready() -> void:
	pass

func set_type(type_: String):
	print("Setting resource type to %s" % type_)
	resource_name = type_
	sprite2D.frame = resource_name_to_frame[type_]

func set_qty(qty_: int):
	qty_label.text = str(qty_)


func _process(delta: float) -> void:
	pass
