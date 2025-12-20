extends MultiMeshInstance2D
class_name AgentManager

@export var agent_count: int = 100

var agents: Array[AgentData] = []

@onready var path_network: PathNetwork = get_node("/root/Main/PathNetwork")
@onready var buildings_node: Node2D = get_node("/root/Main/Buildings")
var buildings: Dictionary = {}  # id -> Building

func _ready():
	# 缓存建筑
	for child in buildings_node.get_children():
		if child is Building:
			buildings[child.name] = child
	
	# 初始化 MultiMesh
	setup_multimesh()
	
	# 生成 agents
	spawn_agents()

func setup_multimesh():
	var mesh = QuadMesh.new()
	mesh.size = Vector2(8, 8)  # 小点大小
	
	multimesh = MultiMesh.new()
	multimesh.mesh = mesh
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.use_colors = true
	multimesh.instance_count = agent_count

func spawn_agents():
	var dorm = buildings.get("Dormitory")
	
	for i in agent_count:
		var agent = AgentData.new(i)
		agent.position = dorm.entrance_point
		agent.current_building_id = "Dormitory"
		agent.stay_timer = randf_range(1.0, 4.0)  # 随机初始等待
		agents.append(agent)
	
	dorm.current_count = agent_count
	dorm.update_label()

func _process(delta):
	for agent in agents:
		update_agent(agent, delta)
	
	update_multimesh()

func update_agent(agent: AgentData, delta: float):
	if agent.is_moving:
		# 移动中
		move_agent(agent, delta)
	else:
		# 在建筑内
		agent.stay_timer -= delta
		if agent.stay_timer <= 0:
			update_needs(agent)
			var next_building = decide_next_building(agent)
			if next_building and next_building.name != agent.current_building_id:
				start_moving(agent, next_building)
			else:
				agent.stay_timer = randf_range(2.0, 5.0)

func move_agent(agent: AgentData, delta: float):
	if agent.path_index >= agent.path.size():
		# 到达目的地
		arrive_at_building(agent)
		return
	
	var target = agent.path[agent.path_index]
	if agent.position.distance_to(target) < 5:
		agent.path_index += 1
	else:
		agent.position = agent.position.move_toward(target, agent.speed * delta)

func start_moving(agent: AgentData, target: Building):
	# 离开当前建筑
	if agent.current_building_id != "":
		var old_building = buildings.get(agent.current_building_id)
		if old_building:
			old_building.agent_exit()
	
	# 设置路径
	agent.path = path_network.find_path(agent.position, target.entrance_point)
	agent.path_index = 0
	agent.is_moving = true
	agent.visible = true
	agent.current_building_id = target.name

func arrive_at_building(agent: AgentData):
	agent.is_moving = false
	agent.visible = false
	agent.stay_timer = randf_range(2.0, 5.0)
	
	var building = buildings.get(agent.current_building_id)
	if building:
		building.agent_enter()
		agent.position = building.entrance_point

func update_needs(agent: AgentData):
	agent.energy -= randf_range(5, 15)
	agent.hunger += randf_range(5, 10)
	agent.stress += randf_range(0, 5)
	
	var building = buildings.get(agent.current_building_id)
	if building:
		match building.building_type:
			"residence":
				agent.energy += 20
				agent.stress -= 10
			"study":
				agent.stress += 10
				agent.energy -= 5
			"food":
				agent.hunger -= 30
				agent.energy += 5
	
	agent.energy = clamp(agent.energy, 0, 100)
	agent.hunger = clamp(agent.hunger, 0, 100)
	agent.stress = clamp(agent.stress, 0, 100)

func decide_next_building(agent: AgentData) -> Building:
	var best: Building = null
	var best_score = -INF
	var noise = agent.risk_tolerance / 100.0 * 30.0
	
	for b in buildings.values():
		var score = calculate_score(agent, b)
		score += randf_range(-noise, noise)
		if score > best_score:
			best_score = score
			best = b
	
	return best

func calculate_score(agent: AgentData, b: Building) -> float:
	var score = 0.0
	match b.building_type:
		"residence":
			score += (100 - agent.energy) * 0.5
			score += agent.stress * 0.3
		"study":
			score += agent.discipline * 0.4
			score -= (100 - agent.energy) * 0.2
		"food":
			score += agent.hunger * 0.8
	return score

func update_multimesh():
	var visible_index = 0
	
	for agent in agents:
		if agent.visible and visible_index < agent_count:
			var t = Transform2D()
			t.origin = agent.position
			multimesh.set_instance_transform_2d(visible_index, t)
			multimesh.set_instance_color(visible_index, agent.get_color())
			visible_index += 1
	
	# 隐藏剩余的实例（移到屏幕外）
	for i in range(visible_index, agent_count):
		var t = Transform2D()
		t.origin = Vector2(-1000, -1000)
		multimesh.set_instance_transform_2d(i, t)
