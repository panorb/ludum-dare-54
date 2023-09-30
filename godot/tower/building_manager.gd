class_name BuildingManager
extends Node2D

const SUPPORT_PERCENTAGE : int = 0.8 # Percentage of building bottom that needs to be supported by other buidings
const BUILDING_LAYER : int = 1
const MAP_SIZE : Vector2i = Vector2i(26, 10000)
const FOUNDATION_WIDTH : int = 8

#@onready var tilemap : TileMap = get_node("./MainBuilding")
var map : Building


# Called when the node enters the scene tree for the first time.
func _ready():
	self.map = Building.new(MAP_SIZE)
	self.init_foundation(FOUNDATION_WIDTH)
	var b = Building.new(Vector2i(3, 5))
	b.graphical_tiles.set_cell(0, Vector2i(0, 0), 0)
	b.graphical_tiles.set_cell(0, Vector2i(0, 1), 1)
	b.graphical_tiles.set_cell(0, Vector2i(1, 0), 2)

	self.place_building(Vector2i(5, 7), b)
	#print(map.tile_info[0])
	self.add_child(self.map.graphical_tiles)
	self.map.graphical_tiles.tile_set = TileSet.new()
	#self.map.graphical_tiles.tile_set.add_source(source)

func init_foundation(width):
	var foundation = Building.new(Vector2i(FOUNDATION_WIDTH, 1))
	#print(foundation.tile_info)
	for i in range(FOUNDATION_WIDTH):
		foundation.set_supports(Vector2i(i, 0), true)
		#print(str(i)+": "+str(foundation.get_supports(Vector2i(i, 0))))
	var offset = int(MAP_SIZE.x / 2) - int(width / 2)
	for i in range(width):
		foundation.set_supports(Vector2i(i, 0))
	self.map.stamp(Vector2i(offset, 0), foundation)
	#print(foundation.tile_info)

# test if building could be placed
func test_placement(position:Vector2i, building:Building) -> bool:
	var size = building.size
	if position.x < 0 or position.x + size.x > MAP_SIZE.x:
		return false
	return true

# place building
func place_building(position:Vector2i, building:Building) -> bool:
	if not test_placement(position, building):
		return false
	#self.tilemap.set_pattern(BUILDING_LAYER, position, building.graphical_tiles)
	self.map.stamp(position, building)
	return true
