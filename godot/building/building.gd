class_name Building extends Node

@export var floor_height = 3

@export var min_width : int = 2
@export var max_width : int = 10
@export var floor_width_distribution = [0, 0, 0.1, 0.25, 0.4, 0.55, 0.7, 0.8, 0.9, 0.96, 1]
@export var floor_number_distribution = [0, 0.3, 0.4, 1]
@export var border_probability = 0.3
@export var left_border_probability = 0.5
@export var adjusted_expanding_distribution = [0.02, 0.22, 0.68, 0.98, 1]
@export var no_tshape_probability = 0.2

var grid = []
var size = Vector2i.ZERO

func generate_building():
	var floor_number = randomize_floor_number()
	var upper_height = randomize_upper_height(floor_number)
	
	var is_border = randomize_border()
	var is_left_border_if_border = randomize_left_border()
	
	var lower_size = randomize_size()
	
	var upper_size = randomize_size()
	if (floor_number == 1):
		upper_size = lower_size
	
	var offset = randomize_offset(lower_size, upper_size, is_border, is_left_border_if_border)
	
	var expand_size = 0
	if is_border:
		expand_size = randomize_expand_size(lower_size, upper_size)
	
	for i in floor_height * floor_number:
		grid.append([])
		for j in max(lower_size, upper_size):
			var tile_instance = Building_Tile.new()
			grid[i].append(tile_instance)

	for i in floor_height * upper_height:
		for j in upper_size:
			grid[i][-offset+j].set_brick()
	
	for i in floor_height * (floor_number - upper_height):
		for j in lower_size:
			grid[i+floor_height*upper_height][offset+j].set_brick()
	
	if is_border:
		if expand_size > 0:
			if is_left_border_if_border:
				for i in expand_size:
					for j in expand_size - i:
						grid[i][j].unset_brick()
						if i+j == expand_size - 1:
							grid[i][j].set_slope(1)
			else:
				for i in expand_size:
					for j in expand_size - i:
						grid[i][upper_size-1-j].unset_brick()
						if i+j == expand_size - 1:
							grid[i][upper_size-1-j].set_slope(2)
		if expand_size < 0:
			if is_left_border_if_border:
				for i in expand_size:
					for j in expand_size - i:
						grid[floor_height-1-i][j].unset_brick()
						if i+j == expand_size - 1:
							grid[floor_height-1-i][j].set_slope(3)
			else:
				for i in expand_size:
					for j in expand_size - i:
						grid[floor_height-1-i][upper_size-1-j].unset_brick()
						if i+j == expand_size - 1:
							grid[floor_height-1-i][upper_size-1-j].set_slope(4)

	for j in max(lower_size, upper_size):
		if not grid[0][j].is_empty:
			grid[0][j].set_top()

	for j in max(lower_size, upper_size):
		if not grid[floor_number*floor_height-1][j].is_empty:
			grid[floor_number*floor_height-1][j].set_bottom()
	
	self.size.y = floor_number*floor_height
	self.size.x = max(upper_size, lower_size)

func randomize_floor_number():
	var random = randf()
	var floor_number = 0
	while floor_number_distribution[floor_number] < random:
		floor_number += 1
	return floor_number

func randomize_upper_height(floor_number):
	if floor_number <= 2:
		return 1
	return randi_range(1, floor_number - 1)
	

func randomize_border():
	return randf() < border_probability
	
func randomize_left_border():
	return randf() < left_border_probability
	
func randomize_size():
	var random = randf()
	var floor_width = 0
	while floor_width_distribution[floor_width] < random:
		floor_width += 1
	return floor_width

func randomize_offset(lower_size, upper_size, is_border, is_left_border_if_border):
	if is_border:
		if is_left_border_if_border:
			return 0
		else:
			return upper_size-lower_size
	if randf() < no_tshape_probability:
		if randf() < 0.5:
			return max(upper_size-lower_size, 0)
		else:
			return min(upper_size-lower_size, 0)
	var max_offset = max(upper_size-lower_size, 0)
	var min_offset = min(upper_size-lower_size, 0)
	return randi_range(min_offset, max_offset)

func randomize_expand_size(lower_size, upper_size):
	var random = randf()
	var adjusted_expand_size = 0
	while adjusted_expanding_distribution[adjusted_expand_size] < random:
		adjusted_expand_size += 1
	var expand_size = adjusted_expand_size - 2
	
	expand_size = max(expand_size, min_width - lower_size, min_width - upper_size)
	expand_size = min(expand_size, lower_size - min_width, upper_size - min_width)
	
	return expand_size
