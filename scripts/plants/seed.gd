extends Node2D
class_name Seed

var start_cell: Vector2i
var target_cell: Vector2i
var target_pos: Vector2

signal landed(cell: Vector2i)
var speed = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var world = get_parent() as World
	target_pos = world.board.local_to_map(target_cell)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = position.move_toward(target_pos, speed*delta)
	if position.distance_to(target_pos)<2:
		land()
		
func land():
	emit_signal("landed", target_cell)
	queue_free()
