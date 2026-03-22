extends Control
class_name BaseCard

signal card_selected(card)

@export var name_label:Label = null
@export var icon:TextureRect = null
@export var cursor: Texture2D = null

var card_data: CardData	
# tree, mineral, plant, human, crittor, 
# rain, wind, sun, thunder, quake, meteor
# inspect, sample
# remove, kill, plague

func _ready() -> void:
	gui_input.connect(_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			set_select()

func set_select():
	if (cursor):
		Input.set_custom_mouse_cursor(cursor)
	emit_signal("card_selected", self)
	hide()
	
func setup(data: CardData):
	card_data = data
	name_label.text = data.name
	icon.texture = data.icon
	cursor = data.cursor
	
	match data.card_type:
		card_data.CardType.ENVIRONMENT:
			modulate = Color(0.8, 0.7, 0.1, 1.0)
		card_data.CardType.ANIMAL:
			modulate = Color(0.9, 0.7, 0.3, 1.0)
		card_data.CardType.MATERIAL:
			modulate = Color(0.7, 0.8, 0.9, 1.0)
				
	
	if (data.logic_script != null):
		set_script(data.logic_script)

func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property($CardVisual, "position:y", -50, 0.15)

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property($CardVisual, "position:y", 0, 0.15)

func use(world: World , cell: Cell):
	pass
	
func useable(world:World, cell:Cell)->bool:
	return false
