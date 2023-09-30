class_name TBuilding
extends Node

var size : Vector2i
var graphical_tiles : TileMap
var tile_info = []
var offset : Vector2i

const SUPPORTS_BUILDING : int = 1
const NEEDS_SUPPORT : int = 2
const DOOR : int = 4
const WINDOW : int = 8
const SLOPE : int = 16

func _init(size:Vector2i, tile_map:TileMap = null, offset = Vector2i(0, 0)):
	self.size = size
	self.offset = offset
	if tile_map == null:
		self.graphical_tiles = TileMap.new()
	else:
		self.graphical_tiles = tile_map
	for y in range(size.y):
		self.tile_info.append([])
		for x in range(size.x):
			self.tile_info[y].append(0)

# copy the building into my own map
func stamp(pos:Vector2i, building):
	for y in range(building.size.y):
		for x in range(building.size.x):
			var pos_in = Vector2i(x, y)
			var pos_tl = pos + pos_in
			if self.graphical_tiles.get_cell_source_id(0, pos_tl-offset) == -1:
				self.graphical_tiles.set_cell(0, pos_tl-offset, building.graphical_tiles.get_cell_source_id(0, pos_in), building.graphical_tiles.get_cell_atlas_coords(0, pos_in))
				self.tile_info[pos_tl.y][pos_tl.x] = building.tile_info[y][x]

static func from_building(building):
#	var b = TBuilding.new(Vector2i(3, 5))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 1), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(1, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(2, 0), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(2, 4), 0, Vector2i(0, 0))
#	b.graphical_tiles.set_cell(0, Vector2i(0, 4), 0, Vector2i(0, 0))
#	b.set_needs_suppot(Vector2i(2, 4))
#	b.set_needs_suppot(Vector2i(0, 4))
#	return b
	var tbuilding = TBuilding.new(building.size)
	for y in range(tbuilding.size.y):
		for x in range(tbuilding.size.x):
			if not building.grid[y][x].is_empty:
				tbuilding.graphical_tiles.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 1))
			else:
				if building.grid[y][x].slope:
					if building.grid[y][x].slope == 1:
						tbuilding.graphical_tiles.set_cell(0, Vector2i(x, y), 0, Vector2i(5, 2))
					elif building.grid[y][x].slope == 2:
						tbuilding.graphical_tiles.set_cell(0, Vector2i(x, y), 0, Vector2i(6, 2))
					if building.grid[y][x].slope == 3:
						tbuilding.graphical_tiles.set_cell(0, Vector2i(x, y), 0, Vector2i(5, 3))
					elif building.grid[y][x].slope == 4:
						tbuilding.graphical_tiles.set_cell(0, Vector2i(x, y), 0, Vector2i(6, 3))
			
			#tbuilding.set_needs_suppot(Vector2i(x, y))
	return tbuilding

func set_tile(pos:Vector2i, tile):
	# self.graphical_tiles.set_cell(0, pos, tile.graphic_source_id, tile.graphic_coords)
	# self.set_supports(pos, tile.supports)
	# self.set_needs_support(pos, tile.needs_support)
	# self.set_window_property(pos, tile.window)
	# self.set_door(pos, tile.door)
	# self.set_slope(pos, tile.slope)
	pass

func _get_flag(pos:Vector2i, flag:int):
	return (self.tile_info[pos.y][pos.x] & flag) != 0

func _set_flag(pos:Vector2i, value:bool, flag:int):
	if value:
		self.tile_info[pos.y][pos.x] = self.tile_info[pos.y][pos.x] | flag
		return
	self.tile_info[pos.y][pos.x] = self.tile_info[pos.y][pos.x] & (~flag)

func get_supports(pos:Vector2i):
	return self._get_flag(pos, SUPPORTS_BUILDING)

func set_supports(pos:Vector2i, value:bool = true):
	self._set_flag(pos, value, SUPPORTS_BUILDING)

func get_needs_suppot(pos:Vector2i):
	return self._get_flag(pos, NEEDS_SUPPORT)

func set_needs_suppot(pos:Vector2i, value:bool = true):
	self._set_flag(pos, value, NEEDS_SUPPORT)

func get_window_property(pos:Vector2i):
	return self._get_flag(pos, WINDOW)

func set_window_property(pos:Vector2i, value:bool = true):
	self._set_flag(pos, value, WINDOW)

func get_door(pos:Vector2i):
	return self._get_flag(pos, DOOR)

func set_door(pos:Vector2i, value:bool = true):
	self._set_flag(pos, value, DOOR)

func get_slope(pos:Vector2i):
	return self._get_flag(pos, SLOPE)

func set_slope(pos:Vector2i, value:bool = true):
	self._set_flag(pos, value, SLOPE)
