extends BaseCard
class_name SunCard

func use(world: World , cell: Vector2i):
	var board = world.board as Board
	
	for x in range(cell.x - GameConfig.AFFECT_RANGE, cell.x + GameConfig.AFFECT_RANGE + 1):
		var dx = x - cell.x
		var y_range = GameConfig.AFFECT_RANGE - abs(dx)
		
		for y in range(cell.y - y_range, cell.y + y_range + 1):
			var dist = abs(x - cell.x) + abs(y - cell.y)
			board.change_cell(x, y, GameConfig.AFFECT_RANGE - dist, -1)
			board.draw_map(x-1,x+1,y-1,y+1)
