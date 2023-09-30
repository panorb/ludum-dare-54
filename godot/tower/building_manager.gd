class_name BuildingManager
extends Node2D

const SUPPORT_PERCENTAGE : int = 0.8 # Percentage of building bottom that needs to be supported by other buidings
const BUILDING_LAYER : int = 1
const MAP_SIZE : Vector2i = Vector2i(26, 10000)
const FOUNDATION_WIDTH : int = 8

#@onready var tilemap : TileMap = get_node("./MainBuilding")
var map : TBuilding

# Called when the node enters the scene tree for the first time.
func _ready():
	self.map = TBuilding.new(MAP_SIZE, get_node("TemplateMap"), Vector2i(MAP_SIZE.x/2, MAP_SIZE.y))
	self.map.graphical_tiles.set_cell(1, Vector2i(1, 1), 1)
	self.init_foundation(FOUNDATION_WIDTH)
#	var b = Building.new(Vector2i(3, 5))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 1), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(1, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(2, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(2, 4), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 4), 0, Vector2i(0, 0))
#	b.set_needs_suppot(Vector2i(2, 4))
#	b.set_needs_suppot(Vector2i(0, 4))
#	var res = self.place_building(Vector2i(10, MAP_SIZE.y-7), b)
#	print(res)

func init_foundation(width):
	var foundation = TBuilding.new(Vector2i(FOUNDATION_WIDTH, 1))
	for i in range(FOUNDATION_WIDTH):
		foundation.set_supports(Vector2i(i, 0), true)
		foundation.graphical_tiles.set_cell(0, Vector2i(i, 0), 0, Vector2i(0, 0))
	var offset = int(MAP_SIZE.x / 2) - int(width / 2)
	for i in range(width):
		foundation.set_supports(Vector2i(i, 0))
	self.map.stamp(Vector2i(offset, MAP_SIZE.y-1), foundation)

# test if building could be placed
func test_placement(position:Vector2i, building:TBuilding) -> bool:
	var size = building.size
	if position.x < 0 or position.x + size.x > MAP_SIZE.x or position.y + size.y > MAP_SIZE.y-1:
		print("size issue")
		return false
	print("testing")
	
	var support_left = Vector2i(size.x+1, -1)
	var support_right = Vector2i(-1, -1)
	print("testing2")
	for y in range(building.size.y):
		for x in range(building.size.x):
			var here = Vector2i(x, y)
#			print(here)
#			if x > 0 and x < MAP_SIZE.x-1:
#				if building.get_window(here) and self.map.graphical_tiles.get_cell_source_id(0, position+here) != -1:
			if building.get_needs_suppot(here):
				if x < support_left.x:
					support_left = here
				if x > support_right.x:
					support_right = here
	if support_left.x > size.x or support_right.x < 0:
		# building needs no support
		return true
	if not self.map.get_supports(position+support_left+Vector2i(0, 1)) or not self.map.get_supports(position+support_right+Vector2i(0, 1)):
		# not enough support
		print("not enough support")
		return false
	return true

# place building
func place_building(position:Vector2i, building:TBuilding) -> bool:
	if not test_placement(position, building):
		return false
	
	self.map.stamp(position, building)
	return true
