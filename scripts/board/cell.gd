extends Node
# biome_rules.gd
class_name Cell

enum Terrain{
	OCEAN, BEACH,
	SOIL,  DESERT, BARREN,
	GRASSLAND, SAVANNA, TUNDRA,
	SNOWFIELD,SWAMP
	# MOUNTAINS, VOLCANIC
	# TROPIC, OIL, TUNDRA, 
}

var biome_name = {
	Terrain.OCEAN:"ocean",
	Terrain.BEACH:"beach",
	Terrain.SOIL:"soil",  
	Terrain.DESERT:"desert",
	Terrain.BARREN:"barren",
	Terrain.GRASSLAND:"grassland", 
	Terrain.SAVANNA:"savanna",
	Terrain.TUNDRA:"tundra",
	Terrain.SNOWFIELD:"snowfield",
	Terrain.SWAMP:"swamp",
}

var x:int
var y:int

var elevation: int
var moisture: int
var temperature: int

const TEMPERATE_COLD = -30
const TEMPERATE_HOT = 30
const MOISTURE_DRY = -30
const MOISTURE_HUMID = 30

const STEP = 10
const INIT_VALUE=0

func get_biome()->Terrain:
	if elevation < INIT_VALUE:
		return Terrain.OCEAN
	elif elevation == INIT_VALUE:
		return Terrain.BEACH
	elif elevation > INIT_VALUE:
		if temperature <= TEMPERATE_COLD:
			if moisture >= MOISTURE_HUMID:
				return Terrain.SNOWFIELD
			elif moisture > MOISTURE_DRY:
				return Terrain.TUNDRA
			else:
				return Terrain.BARREN
		elif temperature < TEMPERATE_HOT:
			if moisture >= MOISTURE_HUMID:
				return Terrain.SWAMP
			elif moisture > MOISTURE_DRY:
				return Terrain.GRASSLAND
			else:
				return Terrain.SOIL
		else:
			if moisture>= MOISTURE_HUMID:
				return Terrain.SWAMP
			elif moisture > MOISTURE_DRY:
				return Terrain.SAVANNA
			else:
				return Terrain.DESERT
	return Terrain.OCEAN

func set_init_ocean():
	elevation = INIT_VALUE-STEP
	temperature = INIT_VALUE
	moisture = MOISTURE_HUMID
	
func set_init_beach():
	elevation = INIT_VALUE
	temperature = INIT_VALUE
	moisture = INIT_VALUE
	
func set_init_soil():
	elevation = INIT_VALUE+STEP
	temperature = INIT_VALUE
	moisture = MOISTURE_DRY

func set_init_grass():
	set_init_soil()
	moisture = INIT_VALUE
	
func set_init_biome(t:Terrain):
	if t==Terrain.OCEAN:
		set_init_ocean()
	if t==Terrain.BEACH:
		set_init_beach()
	if t==Terrain.SOIL:
		set_init_soil()
	if t==Terrain.GRASSLAND:
		set_init_grass()

func add_moisture(count: int):
	moisture += STEP * count
	
func add_temperature(count: int):
	temperature += STEP * count

func is_ocean() -> bool:
	return elevation < INIT_VALUE

func is_land() -> bool:
	return elevation > INIT_VALUE
	
func is_terrain_desert() ->bool:
	return is_land() and temperature >= TEMPERATE_HOT
	
func is_terrain_soil() ->bool:
	return is_land() and temperature < TEMPERATE_HOT and temperature > TEMPERATE_COLD
	
func is_terrain_snowfield() ->bool:
	return is_land() and temperature < TEMPERATE_COLD
	
func is_tundra() -> bool:
	return is_terrain_snowfield() and moisture > MOISTURE_DRY  and moisture < MOISTURE_HUMID
	
func is_grass() -> bool:
	return is_terrain_soil() and moisture > MOISTURE_DRY and moisture < MOISTURE_HUMID
	
func is_savana() -> bool:
	return is_terrain_desert() and moisture > MOISTURE_DRY and moisture < MOISTURE_HUMID
	
func is_swamp() -> bool:
	return is_land() and temperature > TEMPERATE_COLD and moisture >= MOISTURE_HUMID
	
