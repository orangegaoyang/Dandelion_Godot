extends Control
class_name BaseCard

signal card_selected(card)

@export var name_label:Label = null
@export var icon:TextureRect = null
@export var cursor: Texture2D = null

var card_data: CardData

func _ready() -> void:
	gui_input.connect(_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			set_select()

func set_select():
	print("set select--", self, cursor)
	if (cursor):
		Input.set_custom_mouse_cursor(cursor)
	emit_signal("card_selected", self)
	hide()
	
func setup(data: CardData):
	card_data = data
	print("set up--", self, card_data)
	name_label.text = data.name
	icon.texture = data.icon
	cursor = data.cursor
	
	if (data.logic_script != null):
		set_script(data.logic_script)

func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property($CardVisual, "position:y", -20, 0.15)

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property($CardVisual, "position:y", 0, 0.15)

func use(world: World , cell: Vector2i):
	pass
