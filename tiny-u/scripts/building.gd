extends Node2D
class_name Building

@export var building_name: String = "Building"
@export var building_type: String = "default"  # residence, study, food
@export var capacity: int = 100

var current_count: int = 0
var entrance_point: Vector2  # 入口位置，相对于世界坐标

@onready var shape: ColorRect = $Shape
@onready var label: Label = $Label

func _ready():
	entrance_point = global_position + Vector2(shape.size.x / 2, shape.size.y + 10)
	update_label()
	set_color_by_type()

func set_color_by_type():
	var color: Color
	match building_type:
		"residence": color = Color(0.23, 0.51, 0.96, 0.7)  # 蓝
		"study": color = Color(0.13, 0.77, 0.37, 0.7)      # 绿
		"food": color = Color(0.97, 0.45, 0.09, 0.7)       # 橙
		_: color = Color(0.5, 0.5, 0.5, 0.7)
	shape.color = color

func agent_enter():
	current_count += 1
	update_label()

func agent_exit():
	current_count -= 1
	update_label()

func update_label():
	label.text = "%s\n👤 %d" % [building_name, current_count]
