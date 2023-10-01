class_name Building_Tile extends Node

var is_empty = true
var is_top = false
var is_bottom = false
var is_window = false
var is_trap_door = false
var is_door
var slope = 0
var left_right_edge = 0
var tile = Vector2i(-1, -1)
var tile_decoration = Vector2i(-1, -1)
var decoration = 0
var is_decorated = false

func set_brick():
	is_empty = false
	update_tile()

func unset_brick():
	is_empty = true
	update_tile()

func set_slope(new_slope):
	slope = new_slope
	# 1 = upper left
	# 2 = upper right
	# 3 = lower left
	# 4 = lower right
	update_tile()

func set_left_right_edge(edge):
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

func set_window() -> void:
	is_window = true
	is_decorated = true
	update_tile()

func set_trap_door() -> void:
	is_trap_door = true
	is_decorated = true
	update_tile()

func set_decoration(number) -> void:
	decoration = number
	if number:
		is_decorated = true
	# 1 = window
	# 2 = hole
	# 3 = roof
	update_tile()

func update_tile():
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
	
	if decoration:
		if decoration == 1:
			tile_decoration = Vector2i(1, 2)
		if decoration == 2:
			tile_decoration = Vector2i(3, 5)
		if decoration == 3:
			if not is_empty:
				tile_decoration = Vector2i(1, 0)
			elif slope == 1:
				tile_decoration = Vector2i(0, 0)
			else:
				tile_decoration = Vector2i(2, 0)
		if decoration >= 10:
			tile_decoration = Vector2i(6+(decoration-10)/7, 7+(decoration-10)%7)

	if is_window:
		if left_right_edge == 1:
			tile_decoration = Vector2i(0, 2)
		elif left_right_edge == 2:
			tile_decoration = Vector2i(2, 2)
	
	if is_trap_door:
		if is_top:
			if decoration == 3:
				tile_decoration = Vector2i(3, 3)
			else:
				tile_decoration = Vector2i(4, 4)
		elif is_bottom:
			tile_decoration = Vector2i(3, 4)
