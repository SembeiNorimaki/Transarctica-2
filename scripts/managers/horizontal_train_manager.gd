extends Node
class_name HorizontalTrainManager


#Injected by CombatScene
var tile_occupancy_service: TileOccupancyService
var grid_service: GridService

var next_wagon_id = {"Player": 0, "Enemy": 0}
var wagons := {"Player": [], "Enemy": []}

func spawn_train(tile_pos: Vector2i):
	var example_train = ["locomotive", "barracks", "cannon"]
	for wagon_type_ in example_train:
		var wagon_info = WagonTypes.TYPES[wagon_type_]
		var team = wagon_info.team
		print("Spawning a %s at tile %s" % [wagon_type_, tile_pos])
		var id = "w%s%s" % [team[0], next_wagon_id[team]] # Player wagon with id=3 -> wP3
		next_wagon_id[team] += 1

		var wagon = wagon_info.scene.instantiate()
		
		# Dependecy injection
		#wagon.wagon_manager = self
		wagon.grid_service = grid_service

		#wagon.call_defered("initialize", id, team)
		wagon.position = grid_service.tile_to_world(tile_pos)
		wagon.current_tile = tile_pos

		wagons[team].append(wagon)
		# Add to scene tree
		get_node("../../Containers/Wagons").add_child(wagon)
