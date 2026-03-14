extends Node
# biome_rules.gd
class_name Cell

enum Terrain{
	OCREAN, BEACH,
	SOIL,  DESERT, SNOWFIELD,
	GRASSLAND, SAVANA, TUNDRA,
	# MOUNTAINS, VOLCANIC
	# TROPIC,SWAMP, OIL, TUNDRA, 
}

var elevation: float
#var moisture: float
var temperature: float
var vegetation:float

const ELEVATATION_LOW = 0.5
const ELEVATATION_HIGH = 0.8
const TEMPERATE_COLD = 0.3
const TEMPERATE_HOT = 0.8
const VEGETATION_FEATURE = 0.5

const STEP = 0.1
const INIT_VALUE=0.5

func get_biome()->Terrain:
	if elevation < ELEVATATION_LOW:
		return Terrain.OCREAN
	elif elevation == ELEVATATION_LOW:
		return Terrain.BEACH
	elif elevation < ELEVATATION_HIGH:
		if temperature < TEMPERATE_COLD:
			if vegetation>VEGETATION_FEATURE:
				return Terrain.TUNDRA
			else:
				return Terrain.SNOWFIELD
		elif temperature < TEMPERATE_HOT:
			if vegetation>VEGETATION_FEATURE:
				return Terrain.GRASSLAND
			else:
				return Terrain.SOIL
		else:
			if vegetation>VEGETATION_FEATURE:
				return Terrain.SAVANA
			else:
				return Terrain.DESERT
	return Terrain.OCREAN

func set_init_ocrean():
	elevation = ELEVATATION_LOW-STEP
	temperature = INIT_VALUE
	vegetation = INIT_VALUE
	
func set_init_beach():
	elevation = ELEVATATION_LOW
	temperature = INIT_VALUE
	vegetation = INIT_VALUE
	
func set_init_soil():
	elevation = ELEVATATION_LOW+STEP
	temperature = INIT_VALUE
	vegetation = VEGETATION_FEATURE

func set_init_grass():
	elevation = ELEVATATION_LOW+STEP
	temperature = TEMPERATE_COLD+STEP
	vegetation = VEGETATION_FEATURE+STEP
	
func set_init_biome(t:Terrain):
	if t==Terrain.OCREAN:
		set_init_ocrean()
	if t==Terrain.BEACH:
		set_init_beach()
	if t==Terrain.SOIL:
		set_init_soil()
	if t==Terrain.GRASSLAND:
		set_init_grass()
	
func add_vegetation():
	vegetation += STEP
	
func is_ocrean() -> bool:
	return elevation < ELEVATATION_LOW

func is_land() -> bool:
	return elevation < ELEVATATION_HIGH and elevation > ELEVATATION_LOW
	
func is_terrain_desert() ->bool:
	return is_land() and temperature >= TEMPERATE_HOT
	
func is_terrain_soil() ->bool:
	return is_land() and temperature < TEMPERATE_HOT
	
func is_terrain_snowfield() ->bool:
	return is_land() and temperature < TEMPERATE_COLD
	
func is_tundra() -> bool:
	return is_terrain_snowfield() and vegetation>VEGETATION_FEATURE
	
func is_grass() -> bool:
	return is_terrain_soil() and vegetation>VEGETATION_FEATURE
	
func is_savana() -> bool:
	return is_terrain_desert() and vegetation>VEGETATION_FEATURE
	
func get_base_biome() -> Terrain:
	if is_savana():
		return Terrain.DESERT
	if is_grass():
		return Terrain.SOIL
	if is_tundra():
		return Terrain.SNOWFIELD
	if is_terrain_desert() or is_terrain_snowfield() or is_terrain_soil():
		return Terrain.BEACH
	return Terrain.OCREAN
