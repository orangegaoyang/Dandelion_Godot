extends BaseCard
class_name DandelionCard

var dandelion_scene = preload("res://scenes/plants/dandelion.tscn")

func use(world: World, cell: Vector2i):
	var d = dandelion_scene.instantiate()
	world.plant(d, cell)
