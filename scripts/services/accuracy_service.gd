extends Node
class_name AccuracyService

#Injected services
var los_service: LOSService
var grid_service: GridService
var edge_occupancy_service: EdgeOccupancyService

#region public API
func compute_hit_chance(_shooter: Unit, _weapon_component: WeaponComponent, _shooter_tile: Vector2i, _target_tile: Vector2i) -> float:
	return 0.5
#endregion