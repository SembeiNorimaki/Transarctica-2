extends Node

class_name GridService

# Injected by CombatScene
var tile_size: Vector2i
var map_origin: Vector2
var camera_transform: Transform2D


func _ready() -> void:
	pass


func test():
	pass
	# print("GridService tests")
	# print(tile_to_world(Vector2i(0, 0)))
	# print(tile_to_world(Vector2i(1, 0)))
	# print(tile_to_world(Vector2i(0, 1)))
	# print(tile_to_world(Vector2i(1, 1)))

	# print(world_to_tile(Vector2(0, 0)))
	# print(world_to_tile(Vector2(16, 8)))
	# print(world_to_tile(Vector2(32, 16)))
	# print(world_to_tile(Vector2(0, 16)))
	# print(world_to_tile(Vector2(16, 24)))

func tile_to_world(tile: Vector2i) -> Vector2:
	var world_x = (tile.x - tile.y) * tile_size.x / 2
	var world_y = (tile.x + tile.y) * tile_size.y / 2
	return map_origin + Vector2(world_x, world_y)
	
func world_to_tile(world_pos: Vector2) -> Vector2i:
	var p = world_pos - map_origin
	var tile_x = (p.x / (tile_size.x / 2) + p.y / (tile_size.y / 2)) / 2
	var tile_y = (p.y / (tile_size.y / 2) - p.x / (tile_size.x / 2)) / 2
	return Vector2i(floor(tile_x), floor(tile_y))
	

func get_neighbors(tile: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			if x == 0 and y == 0:
				continue
			neighbors.append(tile + Vector2i(x, y))
	return neighbors

func screen_to_world(screen_pos: Vector2) -> Vector2:
	return (-camera_transform.origin + screen_pos) / (camera_transform.get_scale())

func world_to_screen(world_pos: Vector2) -> Vector2:
	return world_pos - camera_transform.origin

func screen_to_tile(screen_pos: Vector2) -> Vector2i:
	return world_to_tile(screen_to_world(screen_pos))

func tile_to_screen(tile_pos: Vector2i) -> Vector2:
	return world_to_screen(tile_to_world(tile_pos))

func update_camera_transform(t: Transform2D) -> void:
	#print("Setting camera transfor to %s" % t)
	camera_transform = t
