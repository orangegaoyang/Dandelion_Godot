extends Node2D
class_name BasePlant

signal died(cell)

var cell: Vector2i

func is_wind_range(origin: Vector2i):
	pass
	
func on_wind(direction: Vector2i):
	pass
