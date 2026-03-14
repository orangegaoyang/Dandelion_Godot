extends Node2D
class_name BaseCreature

signal died

var cell:Vector2i

func kill():
	died.emit(self)
	queue_free()

func tick():
	pass
