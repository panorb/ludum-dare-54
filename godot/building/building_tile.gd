class_name Building_Tile extends Node

var is_empty = true
var is_top = false
var is_bottom = false
var slope = 0
var edge = 0
var tile = Vector2i(-1, -1)

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

func set_edge(new_edge):
	edge = new_edge
	# 1 = upper
	# 2 = lower
	# 3 = left
	# 4 = upper_left
	# 5 = lower_left
	# 6 = right
	# 7 = upper_right
	# 8 = lower_right
	update_tile()

func set_top():
	is_top = true
	update_tile()

func set_bottom():
	is_bottom = true
	update_tile()


func update_tile():
	if not self.is_empty:
		tile = Vector2i(1, 1)
		if self.is_bottom:
			tile = Vector2i(1, 0)
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
#	if self.edge:
#		if self.edge == 3:
#			tile = Vector2i(0, 1)
#		if self.edge == 6:
#			tile = Vector2i(2, 1)
