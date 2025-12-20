extends Node
class_name PathNetwork

# 路口节点
var waypoints: Dictionary = {}  # name -> Vector2
# 连接关系
var connections: Dictionary = {}  # name -> [connected_names]

func _ready():
	# 定义路口
	waypoints = {
		"center": Vector2(600, 400),
		"north": Vector2(600, 200),
		"south": Vector2(600, 600),
		"west": Vector2(300, 400),
		"east": Vector2(900, 400),
	}
	
	# 定义连接
	connections = {
		"center": ["north", "south", "west", "east"],
		"north": ["center"],
		"south": ["center"],
		"west": ["center"],
		"east": ["center"],
	}

func find_path(from_pos: Vector2, to_pos: Vector2) -> Array[Vector2]:
	# 简化版：找最近的路口，走到中心，再走到目标最近的路口
	var start_wp = get_nearest_waypoint(from_pos)
	var end_wp = get_nearest_waypoint(to_pos)
	
	var path: Array[Vector2] = []
	path.append(waypoints[start_wp])
	
	if start_wp != end_wp:
		path.append(waypoints["center"])  # 简化：都经过中心
		path.append(waypoints[end_wp])
	
	path.append(to_pos)
	return path

func get_nearest_waypoint(pos: Vector2) -> String:
	var nearest := ""
	var min_dist := INF
	for wp_name in waypoints:
		var dist = pos.distance_to(waypoints[wp_name])
		if dist < min_dist:
			min_dist = dist
			nearest = wp_name
	return nearest
