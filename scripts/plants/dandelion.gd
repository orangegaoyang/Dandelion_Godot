extends BasePlant
class_name Dandelion

#@onready var sprite = $Sprite2D
#@onready var timer = $Timer

var seed_scene = preload("res://scenes/plants/seed.tscn")
var self_scene = preload("res://scenes/plants/dandelion.tscn")
#enum State{
	#SEEDLING,
	#GROWING,
	#MATURE
#}
#
#var state = State.SEEDLING
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#update_visual()

func on_wind(direction:Vector2i):
	var new_seed = seed_scene.instantiate()
	new_seed.start_cell = cell
	new_seed.target_cell = cell + direction
	
	var world = get_parent()
	world.add_child(new_seed)
	
	new_seed.landed.connect(_on_seed_landed.bind(new_seed))

func _on_seed_landed(cell: Vector2i, seed: Seed):
	var world = seed.get_parent()
	world.plant(self_scene.instantiate(), cell)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#func is_mature() -> bool:
	#return state == State.MATURE
#
#func wither():
	#sprite.modulate= Color(0.5, 0.5, 0.5) #变灰
	#died.emit(cell)
	#queue_free()
#
#func _on_timer_timeout() -> void:
	#match state:
		#State.SEEDLING:
			#state = State.GROWING
		#State.GROWING:
			#state = State.MATURE
		#State.MATURE:
			#timer.stop()
			#return
	#
	#update_visual()
#
#func update_visual():
	#match state:
		#State.SEEDLING:
			#sprite.scale = Vector2(0.3, 0.3)
		#State.GROWING:
			#sprite.scale = Vector2(0.5, 0.5)
		#State.MATURE:
			#sprite.scale = Vector2(0.75, 0.75)
