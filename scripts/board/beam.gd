extends Node2D
class_name Beam

@export var line: Line2D = null

func setup(pos):
	global_position = pos
	var top = Vector2(pos.x, 0)
	var local_top = to_local(top)
	
	line.points = [Vector2.ZERO, local_top]
	
func play():
	var t = create_tween()
	t.tween_property(line, "width", 0, 0.25)
	t.finished.connect(queue_free)
	
	
