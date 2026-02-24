extends Node2D

@onready var board = $Board

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			print(event)
			var cell = board.local_to_map(event.position)
			$UI/CardManager.use_current_card(cell)

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
