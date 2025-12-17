extends Sprite2D

var target := Vector2(500, 300)
var speed := 200.0

func _process(delta):
	if position.distance_to(target) > 5:
		position = position.move_toward(target, speed * delta)
	else:
		# 到达后随机新目标
		target = Vector2(randf_range(100, 800), randf_range(100, 500))
