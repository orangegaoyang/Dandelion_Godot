extends HBoxContainer
class_name CardManager

@export var world: World = null

@onready var BaseCardScene = preload("res://scenes/cards/BaseCard.tscn")
var current_card: BaseCard = null

var wind_data = preload("res://data/wind_card.tres")
var dandelion_data = preload("res://data/dandelion.tres")
	
func _ready() -> void:
	#mouse_filter = MOUSE_FILTER_STOP
	spawn_card(wind_data)
	spawn_card(dandelion_data)

func spawn_card(card_data: CardData):
	var card = BaseCardScene.instantiate()
	add_child(card)
	card.setup(card_data)
	card.card_selected.connect(_on_card_selected)

func _on_card_selected(card: BaseCard):
	if (current_card != null and current_card!=card):
		current_card.set_unselect()
	current_card = card

func use_current_card(cell: Vector2i):
	print("use current card:", current_card.name)
	if current_card:
		current_card.use(world, cell)
		current_card.queue_free()
		current_card = null
