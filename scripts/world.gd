extends Node2D
class_name World

var plants = {}
#key Vector2i(tile)

@export var board:Board = null

func plant(plant:BasePlant, cell: Vector2i):
	plant.cell = cell
	plant.global_position = board.map_to_local(cell)
	plant.died.connect(_release_cell)
	add_child(plant)
	
	plants[cell] = plant

func is_cell_planted(cell: Vector2i):
	return plants.has(cell)

func _release_cell(cell: Vector2i):
	if plants.has(cell):
		plants.erase(cell)
		
func get_all_plants():
	return plants.values()
