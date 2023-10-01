class_name Building extends Node

@export var floor_height = 3

@export var min_width : int = 2
@export var max_width : int = 10
@export var floor_width_distribution = [0, 0, 0.1, 0.25, 0.4, 0.55, 0.7, 0.8, 0.9, 0.96, 1]
@export var floor_number_distribution = [0, 0.3, 0.4, 1]
@export var border_probability = 1
@export var left_border_probability = 0.5
@export var adjusted_expanding_distribution = [10.05, 0.22, 0.68, 0.98, 1]
@export var no_tshape_probability = 0.2

var grid = []
var size = Vector2i.ZERO

func generate_building() -> void:
	var floor_number := randomize_floor_number()
	var upper_height := randomize_upper_height(floor_number)
	
	var is_border := randomize_border()
	var is_left_border_if_border = randomize_left_border()
	
	var lower_width := randomize_size()
	
	var upper_width := randomize_size()
	if (floor_number == 1):
		upper_width = lower_width
	
	var max_width: int = max(lower_width, upper_width)
	
	size.y = floor_number*floor_height
	size.x = max(upper_width, lower_width)
	
	var offset := randomize_offset(lower_width, upper_width, is_border, is_left_border_if_border)
	
	var shrink_size: int = 0
	if is_border:
		shrink_size = randomize_shrink_size(lower_width, upper_width)
	
	initialize_grid()
	
	for i in floor_height * upper_height:
		for j in upper_width:
			grid[i][-offset+j].set_brick()
	
	for i in floor_height * (floor_number - upper_height):
		for j in lower_width:
			grid[i+floor_height*upper_height][offset+j].set_brick()
	
	
	if is_border:
		if shrink_size > 0:
			if is_left_border_if_border:
				for i in shrink_size:
					for j in shrink_size - i:
						grid[i][j].unset_brick()
						if i+j == shrink_size - 1:
							grid[i][j].set_slope(1)
			else:
				for i in shrink_size:
					for j in shrink_size - i:
						grid[i][max_width-1-j].unset_brick()
						if i+j == shrink_size - 1:
							grid[i][max_width-1-j].set_slope(2)
		if shrink_size < 0:
			if is_left_border_if_border:
				for i in -shrink_size:
					for j in -shrink_size - i:
						grid[floor_height*floor_number-1-i][j].unset_brick()
						if i+j == -shrink_size - 1:
							grid[floor_height*floor_number-1-i][j].set_slope(3)
			else:
				for i in -shrink_size:
					for j in -shrink_size - i:
						grid[floor_height*floor_number-1-i][max_width-1-j].unset_brick()
						if i+j == -shrink_size - 1:
							grid[floor_height*floor_number-1-i][max_width-1-j].set_slope(4)

	for j in max_width:
		if not grid[0][j].is_empty:
			grid[0][j].set_top()
		if floor_number > 1:
			if (not grid[floor_height*upper_height][j].is_empty) and grid[floor_height*upper_height-1][j].is_empty:
				grid[floor_height*upper_height][j].set_top()

	for j in max_width:
		if not grid[floor_number*floor_height-1][j].is_empty:
			grid[floor_number*floor_height-1][j].set_bottom()
		if floor_number > 1:
			if (not grid[floor_height*upper_height-1][j].is_empty) and grid[floor_height*upper_height][j].is_empty:
				grid[floor_height*upper_height-1][j].set_bottom()
	
	update_edges()

func randomize_floor_number() -> int:
	var random := randf()
	var floor_number: int = 0
	while floor_number_distribution[floor_number] < random:
		floor_number += 1
	return floor_number

func randomize_upper_height(floor_number) -> int:
	if floor_number <= 2:
		return 1
	return randi_range(1, floor_number - 1)
	

func randomize_border() -> bool:
	return randf() < border_probability
	
func randomize_left_border() -> bool:
	return randf() < left_border_probability
	
func randomize_size() -> int:
	var random = randf()
	var floor_width = 0
	while floor_width_distribution[floor_width] < random:
		floor_width += 1
	return floor_width

func randomize_offset(lower_width, upper_width, is_border, is_left_border_if_border) -> int:
	if is_border:
		if is_left_border_if_border:
			return 0
		else:
			return upper_width-lower_width
	if randf() < no_tshape_probability:
		if randf() < 0.5:
			return max(upper_width-lower_width, 0)
		else:
			return min(upper_width-lower_width, 0)
	var max_offset = max(upper_width-lower_width, 0)
	var min_offset = min(upper_width-lower_width, 0)
	return randi_range(min_offset, max_offset)

func randomize_shrink_size(lower_width, upper_width) -> int:
	var random := randf()
	var adjusted_shrink_size: int = 0
	while adjusted_expanding_distribution[adjusted_shrink_size] < random:
		adjusted_shrink_size += 1
	var shrink_size: int = adjusted_shrink_size - 2
	
	shrink_size = max(shrink_size, min_width - lower_width, min_width - upper_width)
	shrink_size = min(shrink_size, lower_width - min_width, upper_width - min_width)
	
	return shrink_size

func update_edges() -> void:
	for i in size.y:
		for j in size.x:
			grid[i][j].edge = 0
			if not grid[i][j].is_empty:
				if i==0 or (i!=0 and grid[i-1][j].is_empty and not grid[i-1][j].slope):
					grid[i][j].edge += 1 # upper edge
				if i==size.y-1 or (i!=size.y-1 and grid[i+1][j].is_empty and not grid[i+1][j].slope):
					grid[i][j].edge += 2 # lower edge
				if j==0 or (j!=0 and grid[i][j-1].is_empty and not grid[i][j-1].slope):
					grid[i][j].edge += 3 # left edge
				if j==size.x-1 or (j!=size.x-1 and grid[i][j+1].is_empty and not grid[i][j+1].slope):
					grid[i][j].edge += 6 # right edge

func initialize_grid():
	for i in size.y:
		grid.append([])
		for j in size.x:
			var tile_instance = Building_Tile.new()
			grid[i].append(tile_instance)
