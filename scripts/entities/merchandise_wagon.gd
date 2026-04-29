extends VehicleUnit


func set_resource_type(resource: String):
	if resource == null:
		storage.visible = false
	else:
		storage.visible = true
		storage.frame = resource_name_to_frame[resource]

func set_resource_qty(qty: int):
	qty_label.text = str(qty)
