extends Node2D

@export var timer:Timer = null
@export var world:World = null

func _on_timer_timeout():
	world.tick()
