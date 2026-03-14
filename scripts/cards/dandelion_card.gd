extends BaseCard
class_name DandelionCard

var dandelion_scene = preload("res://scenes/creatures/mankind.tscn")

func use(world: World, cell: Vector2i):
	var d = dandelion_scene.instantiate()
	world.add(d, cell)
