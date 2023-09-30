class_name Building_Tile extends Node

var is_empty = true
var is_top = false
var is_bottom = false
var slope = 0

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

func set_top():
	is_top = true
	update_tile()

func set_bottom():
	is_bottom = true
	update_tile()


func update_tile():
	pass
