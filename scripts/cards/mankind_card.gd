extends BaseCard
class_name MankindCard

var man_scene = preload("res://scenes/creatures/mankind.tscn")

func use(world: World , cell: Vector2i):
	var man = man_scene.instantiate()
	world.add_creature(man, cell)
