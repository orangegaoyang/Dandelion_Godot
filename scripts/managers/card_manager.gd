extends HBoxContainer
class_name CardManager

@export var world: World = null

@onready var BaseCardScene = preload("res://scenes/cards/base_card.tscn")
var current_card: BaseCard = null

var wind_data = preload("res://data/wind_card.tres")
var dandelion_data = preload("res://data/dandelion_card.tres")
var mankind_data = preload("res://data/mankind_card.tres")
	
func _ready() -> void:
	#mouse_filter = MOUSE_FILTER_STOP
	spawn_card(mankind_data)

func spawn_card(card_data: CardData):
	var card = BaseCardScene.instantiate()
	card.setup(card_data)
	card.card_selected.connect(_on_card_selected)
	add_child(card)

func _on_card_selected(card: BaseCard):
	print("on card selected", card)
	if (current_card != null and current_card!=card):
		current_card.set_unselect()
	current_card = card

func unselect_card():
	if (current_card):
		current_card.show()
		current_card = null

func use_current_card(cell: Vector2i):
	if current_card:
		current_card.use(world, cell)
		current_card.queue_free()
		current_card = null

func is_card_selected():
	return current_card != null
