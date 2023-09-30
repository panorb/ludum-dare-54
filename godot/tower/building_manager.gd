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
	self.map = Building.new(MAP_SIZE, get_node("TemplateMap"), Vector2i(MAP_SIZE.x/2, MAP_SIZE.y))
	self.map.graphical_tiles.set_cell(1, Vector2i(1, 1), 1)
	self.init_foundation(FOUNDATION_WIDTH)
#	var b = Building.new(Vector2i(3, 5))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 1), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(1, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(2, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(2, 4), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 4), 0, Vector2i(0, 0))
#	var res = self.place_building(Vector2i(10, MAP_SIZE.y-6), b)
#	print(res)

func init_foundation(width):
	var foundation = Building.new(Vector2i(FOUNDATION_WIDTH, 1))
	for i in range(FOUNDATION_WIDTH):
		foundation.set_supports(Vector2i(i, 0), true)
		foundation.graphical_tiles.set_cell(0, Vector2i(i, 0), 0, Vector2i(0, 0))
	var offset = int(MAP_SIZE.x / 2) - int(width / 2)
	for i in range(width):
		foundation.set_supports(Vector2i(i, 0))
	self.map.stamp(Vector2i(offset, MAP_SIZE.y-1), foundation)

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
	
	self.map.stamp(position, building)
	return true
