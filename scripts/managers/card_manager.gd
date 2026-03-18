extends Control
class_name CardManager

var cards=[]
var overlap = 70 #overlap width
var is_first = true
const SHOW_CARDS_NUMBER = 9
var deck = []

@onready var BaseCardScene = preload("res://scenes/cards/base_card.tscn")
var current_card: BaseCard = null

var wind_data = preload("res://data/wind_card.tres")
#var dandelion_data = preload("res://data/dandelion_card.tres")
var mankind_data = preload("res://data/mankind_card.tres")
	
func _ready() -> void:
	init_deck()
	spawn_card_with_anim(mankind_data)

func init_deck():
	deck.clear()
	for i in 10:
		deck.append(wind_data)
	for i in 1:
		deck.append(mankind_data)
	
	deck.shuffle()

func spawn_card_with_anim(card_data: CardData):
	var card = BaseCardScene.instantiate()
	card.setup(card_data)
	card.card_selected.connect(_on_card_selected)
	add_child(card)
	
	var target_pos = Vector2((SHOW_CARDS_NUMBER-cards.size()) * overlap, card.position.y)
	## 起始位置：屏幕右侧外面
	card.position = Vector2(-200, card.position.y)
	card.z_index = SHOW_CARDS_NUMBER-cards.size()
	
	# 动画滑入
	var tween = create_tween()
	tween.tween_property(card, "position", target_pos, 0.3)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

	cards.append(card)


func spawn_random_cards():
	var num = SHOW_CARDS_NUMBER - cards.size()
	for i in num:
		if deck.size() ==0:
			break
		
		var index = randi() % deck.size()
		spawn_card_with_anim(deck[index])
		deck.remove_at(index)	
		
func _on_card_selected(card: BaseCard):
	if (current_card != null and current_card!=card):
		current_card.set_unselect()
	current_card = card

func unselect_card():
	if (current_card):
		current_card.show()
		current_card = null

func is_card_selected():
	return current_card != null

func use_current_card(cell: Vector2i, world: World):
	if current_card:
		current_card.use(world, cell)
		cards.erase(current_card)
		current_card.queue_free()
		current_card = null
		rearrange_cards()
		spawn_random_cards()

func rearrange_cards():
	for i in cards.size():
		var card = cards[i]
		card.position.x = (SHOW_CARDS_NUMBER- i)* overlap
		card.z_index = SHOW_CARDS_NUMBER- i
