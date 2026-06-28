extends VehicleUnit
class_name BarracksWagon

signal unload_soldiers

func _unload_soldiers():
	# for now just crate a generic unit in the combat scene
	# print("Unloading soldiers from barracks wagon")
	unload_soldiers.emit()


func on_click():
    _unload_soldiers()
