class_name BuildingManager
extends Node2D

const SUPPORT_PERCENTAGE : int = 0.8 # Percentage of building bottom that needs to be supported by other buidings
const BUILDING_LAYER : int = 1
const MAP_SIZE : Vector2i = Vector2i(26, 10000)
const FOUNDATION_WIDTH : int = 12

var map : TBuilding
var height : int
var preview_building : TBuilding = null
@onready var preview_map : TileMap = get_node("PreviewMap")
var preview_pos : Vector2i = Vector2i.ZERO
var blocker : TBuilding = null

signal building_placed(position:Vector2i, capacity:int)


func _ready() -> void:
	self.blocker = TBuilding.new(Vector2i(1, 1))
	self.blocker.set_non_empty(Vector2i(0, 0))
	self.blocker.graphical_tiles.set_cell(0, Vector2i(0, 0), 0, Vector2i(0, 3))
	self.map = TBuilding.new(Vector2i(MAP_SIZE.x, MAP_SIZE.y+1), get_node("TowerMap"), Vector2i(MAP_SIZE.x/2, MAP_SIZE.y-1))
	
	self.init_foundation(FOUNDATION_WIDTH)
	self.height = 1
	var b = Building.new()
	b.generate_base()
	var base = TBuilding.from_building(b)
	var position = get_possible_placement(base)
	self.map.stamp(position[0], base)
	
	var failed_count:int = 0
	for i in range(10):
		b = Building.new()
		if randf() < 0.1:
			b.generate_scaffold()
		else:
			b.generate_building()
		var tb = TBuilding.from_building(b)

		var positions = get_possible_placement(tb, true)
		if not positions:
			failed_count += 1
			continue
		var number = randi() % positions.size()
		self.map.stamp(positions[number], tb)
		self.height = max(self.height, MAP_SIZE.y - positions[number].y)

func get_mouse_position():
	var camera_position = get_local_mouse_position()
	var mouse_position_global = get_tree().get_root().get_node("Game").get_global_mouse_position()
	return mouse_position_global/3 + camera_position
	

func _process(delta):
	if self.preview_building == null:
		return
	var mouse_position = get_mouse_position()
	var building_offset = Vector2i(self.preview_building.size.x/2, self.preview_building.size.y/2)
	var map_position = self.map.graphical_tiles.local_to_map(mouse_position)-building_offset
	var preview_center = self.map.graphical_tiles.map_to_local(map_position)-Vector2(8.0, 8.0)
	self.preview_map.position = preview_center
	var placement_pos = map_position + self.map.offset
	
	if map_position != self.preview_pos:
		self.preview_pos = map_position
		var valid = self.test_placement(placement_pos, self.preview_building)
		
		if valid:
			self.preview_map.modulate = Color(0.8, 0.8, 0.8)
		else:
			self.preview_map.modulate = Color(0.6, 0.0, 0.0)


func init_foundation(width: int) -> void:
	var foundation = TBuilding.new(Vector2i(FOUNDATION_WIDTH, 1))
	
	var offset = int(MAP_SIZE.x / 2) - int(width / 2)
	for i in range(width):
		foundation.set_supports(Vector2i(i, 0))
	self.map.stamp(Vector2i(offset, MAP_SIZE.y-1), foundation)

func get_possible_placement(building:TBuilding, find_all:bool = false) -> Array[Vector2i]:
	var positions : Array[Vector2i] = []
	
	for y in range(MAP_SIZE.y - self.height - building.size.y - 10, min(MAP_SIZE.y-1, MAP_SIZE.y - self.height + 50)):
		for x in range(0, MAP_SIZE.x-building.size.x):
			var pos = Vector2i(x, y)
			if test_placement(pos, building):
				if not find_all:
					return [pos]
				positions.append(pos)
	return positions

# Test if building could be placed
func test_placement(position:Vector2i, building:TBuilding) -> bool:
	var size = building.size
	if position.x < 0 or position.x + size.x > MAP_SIZE.x or position.y + size.y > MAP_SIZE.y-1:
		# Size issue
		return false
	
	if building.support_left.x > size.x or building.support_right.x < 0:
		# Building needs no support
		return true
	
	for y in range(building.size.y):
		for x in range(building.size.x):
			var here_in = Vector2i(x, y)
			var map_pos = position + here_in
			var here_tl = map_pos - self.map.offset
			if (self.map.graphical_tiles.get_cell_source_id(0, here_tl) != -1 and building.graphical_tiles.get_cell_source_id(0, here_in) != -1):# or \
				# Overlap
				return false
	
	if not self.map.get_supports(position+building.support_left+Vector2i(0, 1)) or not self.map.get_supports(position+building.support_right+Vector2i(0, 1)):
		# Not enough support
		return false
	return true


func place_building(position:Vector2i, building:TBuilding) -> bool:
	if not test_placement(position, building):
		return false
	self.map.stamp(position, building)
	self.height = max(self.height, MAP_SIZE.y - position.y)
	
	building_placed.emit(position, building.capacity)
	return true


func tower_spam_block(position):
	var pos = position+self.map.offset
	if pos.x < 0 or pos.x > MAP_SIZE.x-1 or pos.y < 0 or pos.y > MAP_SIZE.y-1:
		return
	
	for y in range(1):
		for x in range(1):
			self.map.stamp(pos+Vector2i(x,y), self.blocker)

func deselect_preview_building():
	self.preview_map.clear()
	self.preview_building = null

func select_preview_building(building):
	print("selecting preview building")
	self.preview_map.clear()
	self.preview_building = TBuilding.new(building.size, self.preview_map)
	self.preview_building.capacity = building.capacity
	self.preview_building.stamp(Vector2i.ZERO, building)

func place_preview_building():
	if preview_building == null:
		return
	
	var mouse_position = get_mouse_position()
	var building_offset = Vector2i(self.preview_building.size.x/2, self.preview_building.size.y/2)
	var map_position = self.map.graphical_tiles.local_to_map(mouse_position)-building_offset
	var placement_pos = map_position + self.map.offset
	if self.place_building(placement_pos, self.preview_building):
		self.deselect_preview_building()
