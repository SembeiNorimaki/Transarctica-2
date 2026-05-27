extends Node2D
class_name CitiesOverlay

# Injected by NavigationScene
var cities_manager: CitiesManager
var grid_service: GridService


func update():
	_draw()
	queue_redraw()

func _draw():
	for entry_tile in cities_manager.cities.keys():
		var city_data = cities_manager.cities[entry_tile]
		var city_tile = city_data["city_tile"]
		var city_pos = grid_service.tile_to_world(city_tile)
		#var entry_pos = grid_service.tile_to_world(entry_tile)
		draw_circle(city_pos, 10, Color.RED)
		#draw_circle(entry_pos, 10, Color.BLUE)
