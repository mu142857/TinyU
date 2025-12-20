class_name AgentData
extends RefCounted

# 身份
var id: int
var agent_name: String

# 性格（固定）
var discipline: float
var social_need: float
var risk_tolerance: float

# 状态（动态）
var energy: float = 100.0
var stress: float = 0.0
var hunger: float = 0.0

# 位置与移动
var position: Vector2
var path: Array[Vector2] = []
var path_index: int = 0
var speed: float = 300.0
var is_moving: bool = false
var visible: bool = false

# 当前所在建筑
var current_building_id: String = ""

# 计时器
var stay_timer: float = 0.0

func _init(p_id: int):
	id = p_id
	agent_name = "Student_%d" % p_id
	randomize_personality()

func randomize_personality():
	discipline = randf_range(20, 80)
	social_need = randf_range(20, 80)
	risk_tolerance = randf_range(20, 80)

func get_color() -> Color:
	var score = energy - stress * 0.8
	if score > 50:
		return Color(0.13, 0.77, 0.37)  # 绿
	elif score > 20:
		return Color(0.23, 0.51, 0.96)  # 蓝
	elif score > -10:
		return Color(0.92, 0.70, 0.10)  # 黄
	elif score > -30:
		return Color(0.97, 0.45, 0.09)  # 橙
	else:
		return Color(0.94, 0.27, 0.27)  # 红
