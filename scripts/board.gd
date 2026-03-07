extends TileMapLayer
class_name Board

enum Terrain{
	 OCREAN, LAND,  DESERT, GRASSLAND, FOREST, 
	# SNOWFIELD,  TROPIC,
	# SWAMP, MOUNTAINS, VOLCANIC, OIL, TUNDRA, 
}

@export var cardManager:CardManager = null

var map_data = []
var cell_size = tile_set.tile_size

func _ready() -> void:
	generate_map()
	draw_map()

func place_card(world_pos):
	cardManager.use_current_card(local_to_map(world_pos))

func is_inside_map(cell: Vector2i):
	return cell.x >=0 and cell.x< GameConfig.MAP_WIDTH and cell.y>=0 and cell.y< GameConfig.MAP_HEIGHT

func get_map_center() -> Vector2i:
	var used_rect = get_used_rect()  # TileMap 已使用区域
	var center_cell = used_rect.position + used_rect.size / 2
	return center_cell

func generate_map():
	map_data.clear()
	
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.03
	var biome_noise = FastNoiseLite.new()
	biome_noise.seed = randi()
	biome_noise.frequency = 0.02
	
	for x in range(GameConfig.MAP_WIDTH):
		map_data.append([])
		for y in range(GameConfig.MAP_HEIGHT):
			var n = noise.get_noise_2d(x, y)
			if n<-0.1:
				map_data[x].append(Terrain.OCREAN)
			else:
				var biome = biome_noise.get_noise_2d(x, y)

				if biome < 0:
					map_data[x].append(Terrain.DESERT)
				else:
					map_data[x].append(Terrain.GRASSLAND)
					
	for x in range(GameConfig.MAP_WIDTH):
		for y in range(GameConfig.MAP_HEIGHT):
			if map_data[y][x] != Terrain.OCREAN:
				for nx in neighbors8(x, y):  # 上下左右或8方向
					if map_data[nx.y][nx.x] == Terrain.OCREAN:
						map_data[y][x] = Terrain.LAND
						break

func neighbors8(x, y):
	var result = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and nx < GameConfig.MAP_WIDTH and ny >= 0 and ny < GameConfig.MAP_HEIGHT:
				result.append(Vector2(nx, ny))
	return result
	
func draw_map():
	for x in range(GameConfig.MAP_WIDTH):
		for y in range(GameConfig.MAP_HEIGHT):
			var tile
			var shift = choose_tile(x, y)
			match map_data[y][x]:
				Terrain.LAND:
					tile = Vector2i(1,1) + shift
				Terrain.GRASSLAND:
					tile = Vector2i(6,1) + shift
				Terrain.FOREST:
					tile = Vector2i(11,1) + shift
				Terrain.DESERT:
					tile = Vector2i(6,5) + shift
				#Terrain.TROPIC:
					#tile = Vector2i(11,5) + shift
				#Terrain.SNOWFIELD:
					#tile = Vector2i(1,5) + shift
				Terrain.OCREAN:
					tile = Vector2i(16,11)
			
			set_cell(Vector2i(x,y), 0, tile)

func choose_tile(x, y):
	var result =Vector2i(0,0)
	var type = map_data[y][x]  # 当前tile类型
	var comparing_type = Terrain.OCREAN
	match type:
		Terrain.OCREAN:
			return result
		Terrain.LAND:
			comparing_type = Terrain.OCREAN
		Terrain.DESERT:
			comparing_type = Terrain.LAND
		Terrain.GRASSLAND:
			comparing_type = Terrain.DESERT
		Terrain.FOREST:
			comparing_type = Terrain.GRASSLAND
		#Terrain.SNOWFIELD:
			#comparing_type = Terrain
		#Terrain.TROPIC:
			#comparing_type = Terrain
		
	
	var neighbors = neighbors8(x, y)  # 返回8个方向坐标
	
	var different = []  # 记录哪些邻居不是同类
	for n in neighbors:
		if map_data[n.y][n.x] == comparing_type:
			different.append(Vector2(n.x - x, n.y - y))
	
	## 根据不同邻居选择tile
	if different.size() == 0:
		return result
	for d in different:
		if d == Vector2(0, 1):  # 上面是不同类
			result.y = -1
		elif d == Vector2(0, -1):  # 下面不同
			result.y = 1
		elif d == Vector2(1, 0): # 左边不同
			result.x = -1
		elif d == Vector2(-1, 0):  # 右边不同
			result.x = 1
		#elif d == Vector2(-1, -1): # 左上
			#result.x = -1
			#result.y = -1
		#elif d == Vector2(1, -1):  # 右上
			#result.x = -1
			#result.y = 1
		#elif d == Vector2(-1, 1):  # 左下
			#result.x = 1
			#result.y = -1
		#elif d == Vector2(1, 1):   # 右下
			#result.x = 1
			#result.y = 1


	return result
