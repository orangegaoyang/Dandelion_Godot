extends Node2D
class_name World

var plants = {}
var map_height = 120
var map_width = 120

@export var board:Board = null
@export var camera:Camera2D = null

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				camera.start_drag(event.position)
			else:
				camera.stop_drag()
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pass
			#board.place_card(camera.get_screen_to_world(event.position))

	if event is InputEventMouseMotion:
		camera.drag(event)

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
