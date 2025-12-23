extends Node2D
class_name PathNetwork

var nav_map: RID

func _ready():
	await get_tree().process_frame
	nav_map = get_world_2d().get_navigation_map()

func find_path(from_pos: Vector2, to_pos: Vector2) -> Array[Vector2]:
	var path = NavigationServer2D.map_get_path(nav_map, from_pos, to_pos, true)
	
	var result: Array[Vector2] = []
	for point in path:
		result.append(point)
	return result
