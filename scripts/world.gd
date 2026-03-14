extends Node2D
class_name World

var plants = {}
var creatures = []
var map_height = 120
var map_width = 120

@export var board:Board = null
@export var camera:Camera2D = null
@export var cardManager:CardManager = null

@onready var beam_scene = preload("res://scenes/main/beam.tscn")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			cardManager.unselect_card()
			board.reset_preview()
			if event.pressed:
				camera.start_drag(event.position)
			else:
				camera.stop_drag()
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var world_pos = camera.get_global_mouse_position()
			board.reset_preview()
			cardManager.use_current_card(board.local_to_map(world_pos))

	if event is InputEventMouseMotion:
		camera.drag(event)
		if (cardManager.is_card_selected()):
			var world_pos = camera.get_global_mouse_position()
			board.set_preview(world_pos)

func plant(plant:BasePlant, cell: Vector2i):
	plant.cell = cell
	plant.global_position = board.map_to_local(cell)
	plant.died.connect(_release_cell)
	add_child(plant)
	
	plants[cell] = plant
	
func add_creature(creature: BaseCreature, cell:Vector2i):
	creature.cell = cell
	creature.global_position = board.map_to_local(cell)
	creature.died.connect(_release_creature)

	var beam = beam_scene.instantiate() as Beam
	beam.setup(creature.global_position)
	add_child(beam)
	beam.play()

	creatures.append(creature)
	add_child(creature)
	
func tick():
	for c in creatures:
		c.tick()

func is_cell_planted(cell: Vector2i):
	return plants.has(cell)

func _release_cell(cell: Vector2i):
	if plants.has(cell):
		plants.erase(cell)

func _release_creature(c: BaseCreature):
	creatures.erase(c)

func get_all_plants():
	return plants.values()
