extends BaseCreature

@export var animate: AnimatedSprite2D = null
var target_pos
var astar: AStarGrid2D = null
var path = null
var path_index =0

const SPEED = 60

func _ready() -> void:
	idle()

func tick():
	if (path == null):
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
	var target = random_target(cell.x, cell.y)
	if (cell == target):
		path = null
	else:
		walk_to(target)

func getAstar() -> AStarGrid2D:
	if (astar == null):
		astar = AStarGrid2D.new()
		astar.region = Rect2i(0,0,GameConfig.MAP_WIDTH, GameConfig.MAP_HEIGHT)
		astar.cell_size = Vector2i(1,1)
		astar.update()
		
		var world = get_parent() as World
		for y in GameConfig.MAP_HEIGHT:
			for x in GameConfig.MAP_WIDTH:
				if (!world.board.is_land(x,y)):
					astar.set_point_solid(Vector2i(x,y), true)
		
	return astar
	
func walk_to(target_cell: Vector2i):
	path = getAstar().get_id_path(cell, target_cell)
	path_index = 0
	animate.play("walk")

func random_target(x,y) -> Vector2i:
	for i in 10:
		var nx = x + randi_range(-5,5)
		var ny = y + randi_range(-5,5)
		var world = get_parent() as World
		if (world.board.is_land(nx, ny)):
			return Vector2i(nx, ny)
	return Vector2i(x, y)

func _process(delta):
	if (path):
		if (path_index >=path.size()):
			path = null
			animate.play("idle")
		else:
			var target = Vector2(path[path_index]) * GameConfig.TILE_SIZE
			var dir = (target - position).normalized()
			
			position += dir * SPEED * delta
			if (position.distance_to(target) <2):
				path_index +=1
			
