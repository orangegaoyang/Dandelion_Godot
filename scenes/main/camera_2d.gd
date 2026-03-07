extends Camera2D

var dragging = false

func _ready() -> void:
	limit_left = 0
	limit_top = 0
	limit_right = GameConfig.MAP_WIDTH * GameConfig.TILE_SIZE - get_screen_center_position().x
	limit_bottom = GameConfig.MAP_HEIGHT * GameConfig.TILE_SIZE- get_screen_center_position().y
	
	#position = get_screen_center_position()

func start_drag(mouse_pos: Vector2):
	dragging = true
	
func stop_drag():
	dragging = false
	
func drag(event: InputEventMouseMotion):
	if not dragging:
		return
	
	position -= event.relative
	position.x = clamp(position.x, limit_left, limit_right)
	position.y = clamp(position.y, limit_top, limit_bottom)
