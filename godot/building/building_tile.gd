class_name Building_Tile extends Node

var is_empty : bool = true
var is_top : bool = false
var is_bottom : bool = false
var is_trap_door : bool = false
var window : int = 0
var roof : int = 0
var hole : int = 0
var plant : int = 0
var is_door : bool = false
var slope : int = 0
var left_right_edge : int = 0
var tile := Vector2i(-1, -1)
var tile_decoration := Vector2i(-1, -1)
var is_decorated : bool = false

func set_brick() -> void:
	is_empty = false
	update_tile()

func unset_brick() -> void:
	is_empty = true
	update_tile()

func set_slope(new_slope) -> void:
	slope = new_slope
	# 1 = upper left
	# 2 = upper right
	# 3 = lower left
	# 4 = lower right
	update_tile()

func set_left_right_edge(edge) -> void:
	left_right_edge = edge
	# 1 = left
	# 2 = right
	update_tile()

func set_top() -> void:
	is_top = true
	update_tile()

func set_bottom() -> void:
	is_bottom = true
	update_tile()

func set_window(number) -> void:
	window = number
	is_decorated = true
	update_tile()

func set_trap_door() -> void:
	is_trap_door = true
	is_decorated = true
	update_tile()

func set_roof(number) -> void:
	roof = number
	is_decorated = true
	update_tile()


func set_hole(number) -> void:
	hole = number
	is_decorated = true
	update_tile()


func set_plant(number) -> void:
	plant = number
	is_decorated = true
	update_tile()

func update_tile() -> void:
	if not self.is_empty:
		if self.left_right_edge == 1:
			if self.is_top:
				tile = Vector2i(12, 0)
			elif self.is_bottom:
				tile = Vector2i(12, 1)
			else:
				tile = Vector2i(0, 1)
		elif self.left_right_edge == 2:
			if self.is_top:
				tile = Vector2i(14, 0)
			elif self.is_bottom:
				tile = Vector2i(14, 1)
			else:
				tile = Vector2i(2, 1)
		else:
			if self.is_top:
				tile = Vector2i(13, 0)
			elif self.is_bottom:
				tile = Vector2i(13, 1)
			else:
				tile = Vector2i(1, 1)
	else:
		tile = Vector2i(-1, -1)
		if self.slope:
			if self.slope == 1:
				tile = Vector2i(5, 2)
			elif self.slope == 2:
				tile = Vector2i(6, 2)
			elif self.slope == 3:
				tile = Vector2i(5, 3)
			elif self.slope == 4:
				tile = Vector2i(6, 3)
	
	if roof:
		if roof == 1:
			if not is_empty:
				tile_decoration = Vector2i(1, 0)
			elif slope == 1:
				tile_decoration = Vector2i(0, 0)
			else:
				tile_decoration = Vector2i(2, 0)
		if roof == 2:
			if not is_empty:
				tile_decoration = Vector2i(7, 4)
			elif slope == 1:
				tile_decoration = Vector2i(6, 4)
			else:
				tile_decoration = Vector2i(8, 4)
		if roof == 3:
			if not is_empty:
				tile_decoration = Vector2i(7, 5)
			elif slope == 1:
				tile_decoration = Vector2i(6, 5)
			else:
				tile_decoration = Vector2i(8, 5)
		if roof == 4:
			if not is_empty:
				tile_decoration = Vector2i(7, 6)
			elif slope == 1:
				tile_decoration = Vector2i(6, 6)
			else:
				tile_decoration = Vector2i(8, 6)
	
	if hole:
		tile_decoration = Vector2i(6+(hole-1)/3, 7+(hole-1)%3)
	
	if plant:
		tile_decoration = Vector2i(6+(plant-1)/4, 10+(plant-1)%4)
	
	if window:
		tile_decoration = Vector2i(3+(window-1)/3, 9+(window-1)%3)
	
	if is_trap_door:
		if is_top:
			if roof:
				if roof == 1:
					tile_decoration = Vector2i(3, 3)
				if roof == 2:
					tile_decoration = Vector2i(3, 3)
				if roof == 3:
					tile_decoration = Vector2i(3, 3)
				if roof == 4:
					tile_decoration = Vector2i(3, 3)
			else:
				tile_decoration = Vector2i(3, 8)
		elif is_bottom:
			tile_decoration = Vector2i(3, 7)
