extends TileMapLayer
class_name Board

var cell_size = tile_set.tile_size

func is_inside_map(cell: Vector2i):
	return cell.x >=0 and cell.x<18 and cell.y>=0 and cell.y<10

func get_map_center() -> Vector2i:
	var used_rect = get_used_rect()  # TileMap 已使用区域
	var center_cell = used_rect.position + used_rect.size / 2
	return center_cell
	
