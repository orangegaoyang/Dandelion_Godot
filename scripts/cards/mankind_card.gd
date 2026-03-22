extends BaseCard
class_name MankindCard

var man_scene = preload("res://scenes/creatures/mankind.tscn")

func use(world: World , cell: Vector2i):
	var man1 = man_scene.instantiate()
	var man2 = man_scene.instantiate()
	world.add_creature(man1, cell)
	world.add_creature(man2, cell)

func usable(world:World, cell:Cell):
	return !cell.is_ocean()
