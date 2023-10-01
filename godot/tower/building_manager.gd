class_name BuildingManager
extends Node2D

const SUPPORT_PERCENTAGE : int = 0.8 # Percentage of building bottom that needs to be supported by other buidings
const BUILDING_LAYER : int = 1
const MAP_SIZE : Vector2i = Vector2i(26, 10000)
const FOUNDATION_WIDTH : int = 12

#@onready var tilemap : TileMap = get_node("./MainBuilding")
var map : TBuilding
var height : int
var preview_building : TBuilding = null
@onready var preview_map : TileMap = get_node("PreviewMap")
var preview_pos : Vector2i = Vector2i.ZERO
var blocker : TBuilding = null

signal building_placed(position:Vector2i)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.blocker = TBuilding.new(Vector2i(1, 1))
	self.blocker.set_non_empty(Vector2i(0, 0))
#	self.blocker.graphical_tiles.set_cell(0, Vector2i(0, 0), 0, Vector2i(0, 0))
	self.map = TBuilding.new(Vector2i(MAP_SIZE.x, MAP_SIZE.y+1), get_node("TowerMap"), Vector2i(MAP_SIZE.x/2, MAP_SIZE.y-1))
	self.map.graphical_tiles.set_cell(1, Vector2i(1, 1), 1)
#	print(self.preview_map)
	self.preview_map.set_cell(0, Vector2i(1, 1), 0, Vector2i(1, 0))
	self.init_foundation(FOUNDATION_WIDTH)
	self.height = 1
	var b = Building.new()
#	b.generate_building()
#	print("here")
#	print(b)
#	var tb = TBuilding.from_building(b)
#	print("Placing building of size"+str(tb.size)+" at "+str(Vector2i(13-(tb.size.x/2), MAP_SIZE.y-(tb.size.y+1))))
#	var res = self.place_building(Vector2i(13-(tb.size.x/2), MAP_SIZE.y-(tb.size.y+1)), tb)
#	print(get_possible_placement(tb, true))
	var failed_count:int = 0
	for i in range(0):
		b = Building.new()
		b.generate_building()
		var tb = TBuilding.from_building(b)
#		while tb.support_left.y < tb.size.y-1 or tb.support_right.y < tb.size.y-1:
#			b.generate_building()
#			tb = TBuilding.from_building(b)
		var positions = get_possible_placement(tb, true)
		if not positions:
#			print("failed")
			failed_count += 1
			continue
		self.place_building(positions[randi() % positions.size()], tb)
#	print("Total failed: "+str(failed_count))
	
#	var b = TBuilding.new(Vector2i(3, 5))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 1), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(1, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(2, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(2, 4), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 4), 0, Vector2i(0, 0))
#	var res = self.place_building(Vector2i(10, MAP_SIZE.y-9), b)
#	b.set_needs_suppot(Vector2i(2, 4))
#	b.set_needs_suppot(Vector2i(0, 4))
#	print(res)
#	res = self.place_building(Vector2i(10, MAP_SIZE.y-6), b)
#	print(res)

func _process(delta):
	if self.preview_building == null:
		return
	var mouse_position = self.get_local_mouse_position()
	var building_offset = Vector2i(self.preview_building.size.x/2, self.preview_building.size.y/2)
	var map_position = self.map.graphical_tiles.local_to_map(mouse_position)-building_offset
	var preview_center = self.map.graphical_tiles.map_to_local(map_position)-Vector2(8.0, 8.0)
	self.preview_map.position = preview_center
	var placement_pos = map_position + self.map.offset
	if map_position != self.preview_pos:
		self.preview_pos = map_position
#		print(placement_pos)
		var valid = self.test_placement(placement_pos, self.preview_building)
#		print("valid: "+str(valid))
		if valid:
			self.preview_map.modulate = Color(0.8, 0.8, 0.8)
		else:
			self.preview_map.modulate = Color(0.6, 0.0, 0.0)
	if Input.is_action_just_released("primary_action"):
		if self.place_building(placement_pos, self.preview_building):
			self.preview_map.clear()
			self.preview_building = null
	#print(preview_center)
	#var tilemap_local_coords = tilemap.to_local(global_coords);
	#tilemap_starting_position = tilemap.local_to_map(tilemap_local_coords);

func init_foundation(width: int) -> void:
	var foundation = TBuilding.new(Vector2i(FOUNDATION_WIDTH, 1))
	for i in range(FOUNDATION_WIDTH):
		foundation.set_supports(Vector2i(i, 0), true)
		#foundation.graphical_tiles.set_cell(0, Vector2i(i, 0), 0, Vector2i(0, 0))
	var offset = int(MAP_SIZE.x / 2) - int(width / 2)
	for i in range(width):
		foundation.set_supports(Vector2i(i, 0))
	self.map.stamp(Vector2i(offset, MAP_SIZE.y-1), foundation)

func get_possible_placement(building:TBuilding, find_all:bool = false) -> Array[Vector2i]:
	var positions : Array[Vector2i] = []
#	print("testing building of size "+str(building.size)+" from "+str(MAP_SIZE.y - self.height - building.size.y - 10)+" to "+str(min(MAP_SIZE.y-1, MAP_SIZE.y - self.height + 50)))
#	for y in range(MAP_SIZE.y - self.height - building.size.y - 10, min(MAP_SIZE.y-1, MAP_SIZE.y - self.height + 50)):
#		for x in range(0, MAP_SIZE.x-building.size.x):
#			var pos = Vector2i(x, y)
	for y in range(MAP_SIZE.y - self.height - building.size.y - 10, min(MAP_SIZE.y-1, MAP_SIZE.y - self.height + 50)):
#		print(y)
		for x in range(0, MAP_SIZE.x-building.size.x):
			var pos = Vector2i(x, y)
			if test_placement(pos, building):
#				print(pos)
				if not find_all:
					return [pos]
				positions.append(pos)
	return positions

# test if building could be placed
func test_placement(position:Vector2i, building:TBuilding) -> bool:
	var size = building.size
	if position.x < 0 or position.x + size.x > MAP_SIZE.x or position.y + size.y > MAP_SIZE.y-1:
#		print("size issue")
		return false
#	print("testing")
	for y in range(building.size.y):
		for x in range(building.size.x):
			var here_in = Vector2i(x, y)
			var here_tl = position + here_in - self.map.offset
			if (self.map.graphical_tiles.get_cell_source_id(0, here_tl) != -1 and building.graphical_tiles.get_cell_source_id(0, here_in) != -1):# or  \
				#(self.map.get_non_empty(here_tl) and building.get_non_empty(here_in)):
#				print("overlap with "+str(here_tl))
				return false
#			if building.get_window_property(here_in):
#				if here_in.x == 0:
#					var outside = here_tl+Vector2i(-1, 0)
#					if (not outside.x < 0) and self.map.get_non_empty(outside):
#						print("window issue")
#						return false
#				if here_in.x == building.size.x-1:
#					var outside = here_tl+Vector2i(1, 0)
#					if (not outside.x > MAP_SIZE.x-1) and self.map.get_non_empty(outside):
#						print("window issue")
#						return false
#	for y in range(building.size.y):
#		# check if collides with existing windows
#		var left_in = Vector2i(0, y)
#		var left_out = position + left_in - self.map.offset + Vector2i(-1, 0)
#		var right_in = Vector2i(building.size.x-1, y)
#		var right_out = position + right_in - self.map.offset + Vector2i(1, 0)
#		if (not left_out.x < 0) and self.map.get_window_property(left_out) and building.get_non_empty(left_in):
#			print("internal window left")
#			return false
#		if (not right_out.x > MAP_SIZE.x-1) and self.map.get_window_property(right_out) and building.get_non_empty(right_in):
#			print("internal window right")
#			return false
	
	if building.support_left.x > size.x or building.support_right.x < 0:
		# building needs no support
#		print("no support needed")
		return true
	if not self.map.get_supports(position+building.support_left+Vector2i(0, 1)) or not self.map.get_supports(position+building.support_right+Vector2i(0, 1)):
		# not enough support
#		print("not enough support")
		return false
	return true

# place building
func place_building(position:Vector2i, building:TBuilding) -> bool:
	if not test_placement(position, building):
		return false
	self.map.stamp(position, building)
	self.height = max(self.height, MAP_SIZE.y - position.y)
#	print(height)
	building_placed.emit(position)
	return true

func tower_spam_block(position):
#	print("tower spam at: "+str(position+self.map.offset))
	var pos = position+self.map.offset
	if pos.x < 0 or pos.x > MAP_SIZE.x-1 or pos.y < 0 or pos.y > MAP_SIZE.y-1:
		return
#	if pos.y > 9990:
#		print(pos)
	#self.map.set_non_empty(pos)
	#self.map.graphical_tiles.set_cell(1, position, 0, Vector2i(0, 0))
	self.map.stamp(pos, self.blocker)

func _on_side_building_right_tower_spam(position):
	tower_spam_block(position)


func _on_side_building_left_tower_spam(position):
	tower_spam_block(position)


func _on_card_hand_card_selected(card):
	self.preview_map.clear()
	self.preview_building = TBuilding.new(card._building.size, self.preview_map)
	self.preview_building.stamp(Vector2i.ZERO, card._building)
