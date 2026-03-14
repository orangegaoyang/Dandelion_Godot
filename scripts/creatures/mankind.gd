extends BaseCreature

@export var animate: AnimatedSprite2D = null
var target_pos

func _ready() -> void:
	idle()

func tick():
	choose_next_action()
	
func choose_next_action():
	var r = randi() % 2
	if r == 0:
		walk_random()
	else:
		idle()

func idle():
	target_pos = null
	animate.play("idle")
	
func walk_random():
	var target = pick_next_cell()
	walk_to(target)
	
func walk_to(next_cell: Vector2i):
	print("walk to ", next_cell)
	cell = next_cell
	var world = get_parent() as World
	target_pos = world.board.map_to_local(cell)
	animate.play("walk")

func pick_next_cell()-> Vector2i:
	var dirs = [
		Vector2i(1,0),
		Vector2i(-1,0),
		Vector2i(0,1),
		Vector2i(0,-1)
	]

	var d = dirs.pick_random()
	return cell + d

func _process(delta):
	if (target_pos):
		var dir = target_pos - global_position

		if dir.length() >= 2:
			global_position += dir.normalized() * 120 * delta
