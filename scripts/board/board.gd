extends Node2D
class_name Board

@export var ocean_layer: TileMapLayer = null
@export var beach_layer: TileMapLayer = null
@export var land_layer: TileMapLayer = null
@export var vegetation_layer: TileMapLayer = null
@export var preview_layer: TileMapLayer = null

const TILE_BEACH = Vector2i(1,1)
const TILE_OCEAN = Vector2i(16,11)

const TILE_SOIL = Vector2i(6, 5)
const TILE_GRASS = Vector2i(6, 1)
const TILE_SWAMP = Vector2i(11, 1)

const TILE_DESERT = Vector2i(11, 5)
const TILE_SAVANNA = Vector2i(6, 9)

const TILE_BARREN = Vector2i(1, 9)
const TILE_TUNDRA = Vector2i(11, 9)
const TILE_SNOWLAND = Vector2i(1, 5)

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

func is_land(x,y) ->bool:
	return _inside(x,y) && !map_data[x][y].is_ocean()

func _ready() -> void:
	generate_map()
	draw_map(0, GameConfig.MAP_WIDTH, 0, GameConfig.MAP_HEIGHT)
	#generate_map_test()
	#draw_map(0, 12, 0, 12)

func change_cell(x:int, y:int, t: int, m: int):
	if _inside(x, y):
		var cell = map_data[x][y] as Cell
		cell.add_temperature(t)
		cell.add_moisture(m)
		print("cell:x-y", x,"-",y, " temperature:", cell.temperature, " moisture", cell.moisture)

#func set_preview(world_pos:Vector2):
	#reset_preview()
	#preview_cell = local_to_map(world_pos)
	#
	#var placeable = !map_data[preview_cell.x][preview_cell.y].is_ocean()
	#var tile = Vector2i(0,0)
	#if (!placeable):
		#tile = Vector2i(1,0)
	#preview_layer.set_cell(preview_cell,0,tile)

func set_preview(placeable:bool):
	reset_preview()

	var tile = Vector2i(0,0)
	if (!placeable):
		tile = Vector2i(1,0)
	preview_layer.set_cell(preview_cell,0,tile)

func reset_preview():
	if (preview_cell):
		preview_layer.erase_cell(preview_cell)
		preview_cell = null
		
func local_to_map(world_pos: Vector2) -> Vector2i:
	return ocean_layer.local_to_map(world_pos)

func map_to_local(cell: Vector2i) -> Vector2:
	return ocean_layer.map_to_local(cell)

func get_map_center() -> Vector2i:
	var used_rect = ocean_layer.get_used_rect()  # TileMap 已使用区域
	var center_cell = used_rect.position + used_rect.size / 2
	return center_cell

func generate_map_test():
	for x in range(GameConfig.MAP_WIDTH):
		map_data.append([])
		for y in range(GameConfig.MAP_HEIGHT):
			var cell = Cell.new() 
			cell.x = x
			cell.y = y
			if (y>=2 and y <=4) and (x>=2 and x<=4):
				cell.set_init_soil()
			elif (y>=1 and y <=5) and (x>=1 and x<=5):
				cell.set_init_beach()
			else:
				cell.set_init_ocean()
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
			cell.x = x
			cell.y = y
			if n< -0.2:
				cell.set_init_ocean()
				map_data[x].append(cell)
			else:
				var vegetation = vegetation_noise.get_noise_2d(x, y)
				if vegetation < 0:
					cell.set_init_grass()
					map_data[x].append(cell)	
				else:
					cell.set_init_soil()
					map_data[x].append(cell)	
					
	smooth()
	smooth()
	smooth()
	add_beach_margin()

func add_beach_margin():
	for x in range(GameConfig.MAP_WIDTH):
		for y in range(GameConfig.MAP_HEIGHT):
			if map_data[x][y].is_ocean() == false:
				for nx in neighbors8(x, y):  # 上下左右或8方向
					if map_data[nx.x][nx.y].is_ocean() == true:
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
	
func draw_map(x1,x2,y1,y2):
	x1 = max(x1,0)
	x2 = min(GameConfig.MAP_WIDTH, x2)
	y1 = max(y1,0)
	y2 = min(GameConfig.MAP_HEIGHT, y2)

	print("tile[3,3] temperature-moisture: ",map_data[3][3].temperature,"-",map_data[3][3].moisture)

	draw_terrain(x1,x2,y1,y2)
	draw_land(x1,x2,y1,y2)
	draw_vegetation(x1,x2,y1,y2)
	
func draw_terrain(x1,x2,y1,y2):
	for x in range(x1,x2):
		for y in range(y1,y2):
			var tile = TILE_OCEAN
			ocean_layer.set_cell(Vector2i(x,y), 0, tile)

			if !map_data[x][y].is_ocean():
				var shift = choose_tile(x, y, Cell.Terrain.OCEAN)
				tile = TILE_BEACH + shift
				beach_layer.set_cell(Vector2i(x,y), 0, tile)
			

func draw_land(x1,x2,y1,y2):
	for x in range(x1,x2):
		for y in range(y1,y2):
			if map_data[x][y].is_land():
				var tile
				var shift = choose_tile(x, y, Cell.Terrain.BEACH)
				if map_data[x][y].is_terrain_desert():
					tile = TILE_DESERT + shift
				elif map_data[x][y].is_terrain_soil():
					tile = TILE_SOIL + shift
				elif map_data[x][y].is_terrain_snowfield():
					tile = TILE_BARREN + shift
				else:
					#这个不可能到的吧
					land_layer.erase_cell(Vector2i(x,y))
				
				if tile:
					land_layer.set_cell(Vector2i(x,y), 0, tile)


func draw_vegetation(x1,x2,y1,y2):
	for x in range(x1,x2):
		for y in range(y1,y2):
			var tile
			var shift = choose_tile(x, y, null)
			if map_data[x][y].is_grass():
				tile = TILE_GRASS + shift
			elif map_data[x][y].is_tundra():
				tile = TILE_TUNDRA + shift			
			elif map_data[x][y].is_savana():
				tile = TILE_SAVANNA + shift
			elif map_data[x][y].is_swamp():
				tile = TILE_SWAMP + shift
			else:
				vegetation_layer.erase_cell(Vector2i(x,y))
			
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
