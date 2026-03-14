extends Camera2D

const drag_cursor = preload("res://assets/cursors/expand-arrows.png")
var dragging = false

func _ready() -> void:
	limit_left = 0
	limit_top = 0
	limit_right = GameConfig.MAP_WIDTH * GameConfig.TILE_SIZE - get_screen_center_position().x
	limit_bottom = GameConfig.MAP_HEIGHT * GameConfig.TILE_SIZE- get_screen_center_position().y
	
	#position = get_screen_center_position()

func start_drag(mouse_pos: Vector2):
	Input.set_custom_mouse_cursor(drag_cursor)
	dragging = true
	
func stop_drag():
	Input.set_custom_mouse_cursor(GameConfig.GAME_CURSOR)
	dragging = false
	
func drag(event: InputEventMouseMotion):
	if not dragging:
		return
	
	position -= event.relative
	position.x = clamp(position.x, limit_left, limit_right)
	position.y = clamp(position.y, limit_top, limit_bottom)
