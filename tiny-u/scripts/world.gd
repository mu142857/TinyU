extends Node2D

@export var agent_scene: PackedScene
@export var agent_count: int = 10

func _ready():
	spawn_agents()

func spawn_agents():
	for i in agent_count:
		var agent = agent_scene.instantiate()
		agent.name = "Agent_%d" % i
		add_child(agent)
