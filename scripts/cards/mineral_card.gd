extends BaseCard
class_name MineralCard

var man_scene = preload("res://scenes/creatures/mankind.tscn")

func use(world: World , cell: Cell):
	pass
	#var man1 = man_scene.instantiate()
	#world.add_creature(man1, cell)

func usable(world:World, cell:Cell):
	return true
