extends Control
class_name BaseCard

signal card_selected(card)

@export var name_label:Label = null
@export var icon:TextureRect = null

var card_data: CardData

func _ready() -> void:
	gui_input.connect(_gui_input)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			set_select()
			emit_signal("card_selected", self)

func set_select():
	print("set select")
	var tween = create_tween()
	tween.tween_property($CardVisual, "position:y", -20, 0.15)
	
func set_unselect():
	var tween = create_tween()
	tween.tween_property($CardVisual, "position:y", 0, 0.15)

func setup(data: CardData):
	card_data = data
	name_label.text = data.name
	icon.texture = data.icon
	
	if (data.logic_script != null):
		set_script(data.logic_script)

func use(world: World , cell: Vector2i):
	pass
