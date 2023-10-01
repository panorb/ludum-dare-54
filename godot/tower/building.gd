class_name TBuilding
extends Node

const SUPPORTS_BUILDING : int = 1
const NEEDS_SUPPORT : int = 2
const DOOR : int = 4
const WINDOW : int = 8
const SLOPE : int = 16
const NON_EMPTY : int = 32

var size : Vector2i
var graphical_tiles : TileMap
var tile_info = []
var offset : Vector2i
var support_left : Vector2i
var support_right : Vector2i


func _init(size: Vector2i = Vector2i.ZERO, tile_map: TileMap = null, offset := Vector2i(0, 0)):
	self.size = size
	self.offset = offset
	self.support_left = Vector2i(size.x+1, -1)
	self.support_right = Vector2i(-1, -1)
	if tile_map == null:
		self.graphical_tiles = TileMap.new()
		self.graphical_tiles.add_layer(1)
	else:
		self.graphical_tiles = tile_map
	for y in range(size.y):
		self.tile_info.append([])
		for x in range(size.x):
			self.tile_info[y].append(0)

# copy the building into my own map
func stamp(pos: Vector2i, building: TBuilding) -> void:
#	print("stamp")
	for y in range(building.size.y):
		for x in range(building.size.x):
			var pos_in = Vector2i(x, y)
			var pos_tl = pos + pos_in
#			print(pos_tl-offset)
			if self.graphical_tiles.get_cell_source_id(0, pos_tl-offset) == -1:
				self.graphical_tiles.set_cell(0, pos_tl-offset, building.graphical_tiles.get_cell_source_id(0, pos_in), building.graphical_tiles.get_cell_atlas_coords(0, pos_in))
				self.graphical_tiles.set_cell(1, pos_tl-offset, building.graphical_tiles.get_cell_source_id(1, pos_in), building.graphical_tiles.get_cell_atlas_coords(1, pos_in))
#				if building.graphical_tiles.get_cell_atlas_coords(1, pos_in).x != -1:
#					print("hey")
				self.tile_info[pos_tl.y][pos_tl.x] = building.tile_info[y][x]
				if self.get_needs_suppot(pos_tl):
					if x < self.support_left.x:
						self.support_left = pos_tl
					if x > self.support_right.x:
						self.support_right = pos_tl

static func from_building(building: Building) -> TBuilding:
	var tbuilding = TBuilding.new(building.size)
	for y in range(tbuilding.size.y):
		for x in range(tbuilding.size.x):
			tbuilding.graphical_tiles.set_cell(0, Vector2i(x, y), 0, building.grid[y][x].tile)
			tbuilding.graphical_tiles.set_cell(1, Vector2i(x, y), 0, building.grid[y][x].tile_decoration)
#			if building.grid[y][x].tile_decoration.x != -1:
#				print("hey "+str(building.grid[y][x].tile_decoration))
#			if tbuilding.graphical_tiles.get_cell_atlas_coords(1, Vector2i(x, y)).x != -1:
#				print("ho")
			if not building.grid[y][x].is_empty:
				tbuilding.set_non_empty(Vector2i(x, y))
			else:
				if building.grid[y][x].slope:
					tbuilding.set_non_empty(Vector2i(x, y))
			tbuilding.set_needs_suppot(Vector2i(x, y), building.grid[y][x].is_bottom)
			tbuilding.set_supports(Vector2i(x, y), building.grid[y][x].is_top)
			tbuilding.set_window_property(Vector2i(x, y), building.grid[y][x].is_window)
			#tbuilding.set_door(Vector2i(x, y), building.grid[y][x].is_door)
	
	for y in range(building.size.y):
		for x in range(building.size.x):
			var here = Vector2i(x, y)
			if tbuilding.get_needs_suppot(here):
				if x < tbuilding.support_left.x:
					tbuilding.support_left = here
				if x > tbuilding.support_right.x:
					tbuilding.support_right = here
	return tbuilding

func set_tile(pos:Vector2i, tile) -> void:
	# self.graphical_tiles.set_cell(0, pos, tile.graphic_source_id, tile.graphic_coords)
	# self.set_supports(pos, tile.supports)
	# self.set_needs_support(pos, tile.needs_support)
	# self.set_window_property(pos, tile.window)
	# self.set_door(pos, tile.door)
	# self.set_slope(pos, tile.slope)
	pass

func _get_flag(pos: Vector2i, flag: int) -> bool:
	return (self.tile_info[pos.y][pos.x] & flag) != 0

func _set_flag(pos: Vector2i, value: bool, flag: int) -> void:
	if value:
		self.tile_info[pos.y][pos.x] = self.tile_info[pos.y][pos.x] | flag
		return
	self.tile_info[pos.y][pos.x] = self.tile_info[pos.y][pos.x] & (~flag)

func get_supports(pos: Vector2i) -> bool:
	return self._get_flag(pos, SUPPORTS_BUILDING)

func set_supports(pos: Vector2i, value := true) -> void:
	self._set_flag(pos, value, SUPPORTS_BUILDING)

func get_needs_suppot(pos:Vector2i) -> bool:
	return self._get_flag(pos, NEEDS_SUPPORT)

func set_needs_suppot(pos: Vector2i, value := true) -> void:
	self._set_flag(pos, value, NEEDS_SUPPORT)

func get_window_property(pos: Vector2i) -> bool:
	return self._get_flag(pos, WINDOW)

func set_window_property(pos: Vector2i, value := true) -> void:
	self._set_flag(pos, value, WINDOW)

func get_door(pos: Vector2i) -> bool:
	return self._get_flag(pos, DOOR)

func set_door(pos: Vector2i, value := true) -> void:
	self._set_flag(pos, value, DOOR)

func get_slope(pos: Vector2i) -> bool:
	return self._get_flag(pos, SLOPE)

func set_slope(pos: Vector2i, value := true) -> void:
	self._set_flag(pos, value, SLOPE)

func get_non_empty(pos: Vector2i) -> bool:
	return self._get_flag(pos, NON_EMPTY)

func set_non_empty(pos: Vector2i, value := true) -> void:
	self._set_flag(pos, value, NON_EMPTY)
#	self.graphical_tiles.set_cell(1, pos-self.offset, 0, Vector2i(2,2))
