extends Node2D
class_name Board

@export var ocrean_layer: TileMapLayer = null
@export var beach_layer: TileMapLayer = null
@export var land_layer: TileMapLayer = null
@export var vegetation_layer: TileMapLayer = null
@export var preview_layer: TileMapLayer = null

var map_data = []
var preview_cell = null

const mask_tile = {
	254:Vector2i(0,0),   # 全连接

	193: Vector2i(-1,-1),    # 左上 N+NW+W
	112: Vector2i(-1, 1),    # 左下 W+SW +S
	7:Vector2i(1,-1),   # 右上 N+NE+E
	28:Vector2i(1,1),    # 右下E+SE+S

	1: Vector2i(0,-1),    # N 不管上方的左右是不是衔接，都是用他
	4: Vector2i(1,0),    # E 不管右方的上下是不是衔接，都是用他
	16: Vector2i(0,1),    # S 不管下方的左右是不是衔接，都是用他
	64: Vector2i(-1,0),    # W 不管左方的上下是不是衔接，都是用他
	
	128:Vector2i(3, 0),    # NW
	2:Vector2i(2,0),  # NE
	8:Vector2i(2,-1),   # SE
	32:Vector2i(3,-1),    # NE
	
	0: Vector2i(0,0),    # 单独
}

func _ready() -> void:
	generate_map()
	draw_map()

func set_preview(world_pos:Vector2):
	reset_preview()
	preview_cell = local_to_map(world_pos)
	
	var placeable = !map_data[preview_cell.x][preview_cell.y].is_ocrean()
	var tile = Vector2i(0,0)
	if (!placeable):
		tile = Vector2i(1,0)
	preview_layer.set_cell(preview_cell,0,tile)

func reset_preview():
	if (preview_cell):
		preview_layer.erase_cell(preview_cell)
		preview_cell = null
		
func local_to_map(world_pos: Vector2) -> Vector2i:
	return ocrean_layer.local_to_map(world_pos)

func map_to_local(cell: Vector2i) -> Vector2:
	return ocrean_layer.map_to_local(cell)

func get_map_center() -> Vector2i:
	var used_rect = ocrean_layer.get_used_rect()  # TileMap 已使用区域
	var center_cell = used_rect.position + used_rect.size / 2
	return center_cell

func generate_map_test():
	for x in range(GameConfig.MAP_WIDTH):
		map_data.append([])
		for y in range(GameConfig.MAP_HEIGHT):
			var cell = Cell.new()
			if (y>=1 and y <=3) and (x>=1 and x<=3):
				cell.set_init_beach()
			else:
				cell.set_init_ocrean()
			map_data[x].append(cell)

func generate_map():
	map_data.clear()
	
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	var biome_noise = FastNoiseLite.new()
	biome_noise.seed = noise.seed + 1
	biome_noise.frequency = 0.03
	var vegetation_noise = FastNoiseLite.new()
	vegetation_noise.seed = noise.seed + 2
	vegetation_noise.frequency = 0.03
	
	for x in range(GameConfig.MAP_WIDTH):
		map_data.append([])
		for y in range(GameConfig.MAP_HEIGHT):
			var n = noise.get_noise_2d(x, y)
			var cell = Cell.new()
			if n< 0:
				cell.set_init_ocrean()
				map_data[x].append(cell)
			else:
				var biome = biome_noise.get_noise_2d(x, y)
				if biome < -0.1:
					var vegetation = vegetation_noise.get_noise_2d(x, y)
					if vegetation < -0.1:
						cell.set_init_grass()
						map_data[x].append(cell)	
					else:
						cell.set_init_soil()
						map_data[x].append(cell)	
					
				else:
					cell.set_init_beach()
					map_data[x].append(cell)
					
	smooth()
	smooth()
	smooth()
	add_beach_margin()

func add_beach_margin():
	for x in range(GameConfig.MAP_WIDTH):
		for y in range(GameConfig.MAP_HEIGHT):
			if map_data[x][y].is_ocrean() == false:
				for nx in neighbors8(x, y):  # 上下左右或8方向
					if map_data[nx.x][nx.y].is_ocrean() == true:
						map_data[x][y].set_init_beach()
						break
						
func smooth():
	var i=0

	for x in range(GameConfig.MAP_WIDTH):
		for y in range(GameConfig.MAP_HEIGHT):
			var counts = {}
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					var nx = x + dx
					var ny = y + dy
					if _inside(nx,ny):
						var t = map_data[nx][ny].get_biome()
						counts[t] = counts.get(t,0) + 1

			var best_type = map_data[x][y].get_biome()
			var best_count = 0
			for t in counts:
				if counts[t] > best_count:
					best_count = counts[t]
					best_type = t
					
			if map_data[x][y].get_biome() != best_type:
				i = i+1
				#print(i, "." , x," ", y, " from ", map_data[x][y].get_biome()," to ",best_type)
				map_data[x][y].set_init_biome(best_type)
			
func _inside(nx, ny) -> bool:
	return nx >= 0 and nx < GameConfig.MAP_WIDTH and ny >= 0 and ny < GameConfig.MAP_HEIGHT
	
func neighbors8(x, y):
	var result = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if _inside(nx,ny):
				result.append(Vector2(nx, ny))
	return result
	
func draw_map():
	draw_terrain()
	draw_land()
	draw_vegetation()
	
func draw_terrain():
	for x in range(GameConfig.MAP_WIDTH):
		for y in range(GameConfig.MAP_HEIGHT):
			var tile = Vector2i(16,11)
			ocrean_layer.set_cell(Vector2i(x,y), 0, tile)

			if !map_data[x][y].is_ocrean():
				var shift = choose_tile(x, y, Cell.Terrain.OCREAN)
				tile = Vector2i(1,1) + shift
				beach_layer.set_cell(Vector2i(x,y), 0, tile)
			

func draw_land():
	for x in range(GameConfig.MAP_WIDTH):
		for y in range(GameConfig.MAP_HEIGHT):
			var tile
			var shift = choose_tile(x, y, Cell.Terrain.BEACH)
			if map_data[x][y].is_terrain_desert():
				tile = Vector2i(11,5) + shift
			elif map_data[x][y].is_terrain_soil():
				tile = Vector2i(6,5) + shift
			elif map_data[x][y].is_terrain_snowfield():
				tile = Vector2i(1,5) + shift
			
			if tile:
				land_layer.set_cell(Vector2i(x,y), 0, tile)


func draw_vegetation():
	for x in range(GameConfig.MAP_WIDTH):
		for y in range(GameConfig.MAP_HEIGHT):
			var tile
			var shift = choose_tile(x, y, null)
			if map_data[x][y].is_grass():
				tile = Vector2i(6,1) + shift
			elif map_data[x][y].is_tundra():
				tile = Vector2i(11,1) + shift
			#elif map_data[x][y].is_savana():
				#tile = Vector2i() + shift
			if (tile):
				vegetation_layer.set_cell(Vector2i(x,y), 0, tile)
			
func choose_tile(x, y, base_biome):
	var result =Vector2i(0,0)
	var neighbors = neighbors8(x, y)  # 返回8个方向坐标
	var mask = 0
	for n in neighbors:
		var test = false
		if base_biome != null:
			test = (map_data[n.x][n.y].get_biome() == base_biome)
		else:
			test = (map_data[n.x][n.y].get_biome() != map_data[x][y].get_biome() )
		
		if test:
			var d = Vector2(n.x - x, n.y - y)
			if d == Vector2(0, -1):  # 上面是不同类
				mask |= 1
			elif d == Vector2(0, 1):  # 下面不同
				mask |= 16
			elif d == Vector2(-1, 0): # 左边不同
				mask |= 64
			elif d == Vector2(1, 0):  # 右边不同
				mask |= 4
			elif d == Vector2(-1, -1): # 左上
				mask |= 128
			elif d == Vector2(1, -1):  # 右上
				mask |= 2
			elif d == Vector2(-1, 1):  # 左下
				mask |= 32
			elif d == Vector2(1, 1):   # 右下
				mask |= 8

	for n in mask_tile:
		if (mask & n) == n:
			return mask_tile[n]
	return result
