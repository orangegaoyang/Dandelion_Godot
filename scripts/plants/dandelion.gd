extends BasePlant
class_name Dandelion

@onready var sprite = $Sprite2D
#@onready var timer = $Timer

var seed_scene = preload("res://scenes/plants/seed.tscn")
var self_scene = preload("res://scenes/plants/dandelion.tscn")
enum State{
	SEEDLING,
	GROWING,
	MATURE,
	WITHER,
}

var state = State.SEEDLING
var age_gap : float = 0.0

@export var grow_time :=3.0
@export var mature_time := 4.0
@export var die_time :=3.0

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_visual()

func on_wind(direction:Vector2i):
	if (state == State.MATURE):
		var new_seed = seed_scene.instantiate()
		new_seed.start_cell = cell
		new_seed.target_cell = cell + direction
		
		var world = get_parent()
		world.add_child(new_seed)
		
		new_seed.landed.connect(_on_seed_landed.bind(new_seed))
		state = State.WITHER
		age_gap = 0

func _on_seed_landed(cell: Vector2i, seed: Seed):
	var world = seed.get_parent()
	world.plant(self_scene.instantiate(), cell)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	age_gap += delta
	update_state()
	
func update_state():
	if state == State.SEEDLING and age_gap >= grow_time:
		state = State.GROWING
		update_visual()
		age_gap = 0
	elif state == State.GROWING and age_gap >= mature_time:
		state = State.MATURE
		update_visual()
		age_gap = 0
	elif state == State.WITHER and age_gap >= die_time:
		die()
	
	
func is_mature() -> bool:
	return state == State.MATURE
#
func die():
	died.emit(cell)
	queue_free()
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
func update_visual():
	match state:
		State.SEEDLING:
			sprite.scale = Vector2(0.3, 0.3)
		State.GROWING:
			sprite.scale = Vector2(0.5, 0.5)
		State.MATURE:
			sprite.scale = Vector2(0.75, 0.75)
		State.WITHER:
			sprite.modulate= Color(0.8, 0.8, 0.8) #变灰
