class_name Building extends Node

@export var floor_height = 3

@export var min_width : int = 2
@export var floor_width_distribution = [0, 0, 0.1, 0.25, 0.4, 0.55, 0.7, 0.8, 0.9, 0.96, 1]
@export var floor_number_distribution = [0, 0.3, 0.4, 1]
@export var border_probability : float = 0.8
@export var border_skew_probability : float = 0.5
@export var adjusted_expanding_distribution = [0.25, 0.6, 0.8, 0.98, 1]
@export var no_tshape_probability : float = 0.2

@export var roof_probability : float = 0.4
@export var border_window_probability : float = 0.2
@export var trap_door_probability : float = 0.25

@export var window_probability : float = 0.4
@export var hole_probability : float = 0.2
@export var plant_probability : float = 0.25

@export var balcony_probability : float = 0.1


var grid = []
var size = Vector2i.ZERO

var is_left_border : bool = false
var is_right_border : bool = false

func generate_building() -> void:
	var floor_number := randomize_floor_number()
	var upper_height := randomize_upper_height(floor_number)
	
	randomize_border()
	
	var lower_width := randomize_size()
	
	var upper_width := randomize_size()
	if (floor_number == 1):
		upper_width = lower_width
	
	var max_width: int = max(lower_width, upper_width)
	
	size.y = floor_number*floor_height
	size.x = max(upper_width, lower_width)
	
	var offset := randomize_offset(lower_width, upper_width)
	
	
	
	initialize_grid()
	
	var color := randi_range(0, 1)
	for i in floor_height * upper_height:
		for j in upper_width:
			grid[i][-offset+j].set_brick(color)
	
	for i in floor_height * (floor_number - upper_height):
		for j in lower_width:
			grid[i+floor_height*upper_height][offset+j].set_brick(color)
	
	
	var shrink_size: int = 0
	if is_left_border or is_right_border:
		shrink_size = randomize_shrink_size(lower_width, upper_width)
		if shrink_size > 0:
			if is_left_border:
				for i in shrink_size:
					for j in shrink_size - i:
						grid[i][max(-offset,0)+j].unset_brick()
						if i+j == shrink_size - 1:
							grid[i][max(-offset,0)+j].set_slope(1)
			if is_right_border:
				for i in shrink_size:
					for j in shrink_size - i:
						grid[i][min(abs(offset)+upper_width, max_width)-1-j].unset_brick()
						if i+j == shrink_size - 1:
							grid[i][min(abs(offset)+upper_width, max_width)-1-j].set_slope(2)
		if shrink_size < 0:
			if is_left_border:
				for i in -shrink_size:
					for j in -shrink_size - i:
						grid[floor_height*floor_number-1-i][max(offset,0)+j].unset_brick()
						if i+j == -shrink_size - 1:
							grid[floor_height*floor_number-1-i][max(offset,0)+j].set_slope(3)
			if is_right_border:
				for i in -shrink_size:
					for j in -shrink_size - i:
						grid[floor_height*floor_number-1-i][min(abs(offset)+upper_width, max_width)-1-j].unset_brick()
						if i+j == -shrink_size - 1:
							grid[floor_height*floor_number-1-i][min(abs(offset)+upper_width, max_width)-1-j].set_slope(4)
	
	update_edges()
	
	generate_balkony()
	
	generate_trap_doors()
	generate_decorations()

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
	

func randomize_border() -> void:
	is_left_border = false
	is_right_border = false
	if randf() >= border_probability:
		return
	if randf() < roof_probability:
		is_left_border = true
		is_right_border = true
	if randf() < border_skew_probability:
		is_left_border = true
	else:
		is_right_border = true
	return
	
func randomize_size() -> int:
	var random := randf()
	var floor_width: int = 0
	while floor_width_distribution[floor_width] < random:
		floor_width += 1
	return floor_width

func randomize_offset(lower_width, upper_width) -> int:
	if is_left_border and not is_right_border:
		return 0
	if is_right_border and not is_left_border:
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
	if is_left_border and is_right_border:
		return 1
	
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
			if not grid[i][j].is_empty:
				if i==0 or (i!=0 and grid[i-1][j].is_empty and not grid[i-1][j].slope):
					grid[i][j].set_top() # upper edge
				if i==size.y-1 or (i!=size.y-1 and grid[i+1][j].is_empty and not grid[i+1][j].slope):
					grid[i][j].set_bottom() # lower edge
				if j==0 or (j!=0 and grid[i][j-1].is_empty and not grid[i][j-1].slope):
					grid[i][j].set_left_right_edge(1) # left edge
				if j==size.x-1 or (j!=size.x-1 and grid[i][j+1].is_empty and not grid[i][j+1].slope):
					grid[i][j].set_left_right_edge(2) # right edge

func initialize_grid() -> void:
	for i in size.y:
		grid.append([])
		for j in size.x:
			var tile_instance = Building_Tile.new()
			grid[i].append(tile_instance)

func generate_decorations() -> void:
	if is_left_border and is_right_border:
		var roof_number = randi_range(1, 4)
		for j in size.x:
			if not grid[0][j].is_empty or grid[0][j].slope:
				grid[0][j].set_roof(roof_number)
	
	for i in size.y:
		for j in size.x:
			if grid[i][j].is_decorated:
				continue
			if grid[i][j].is_empty:
				continue
			if allows_window(i, j) and randf() < window_probability:
				grid[i][j].set_window(randi_range(1, 9))
			if allows_hole(i, j) and randf() < hole_probability:
				grid[i][j].set_hole(randi_range(1,12))
			if allows_plant(i, j) and randf() < plant_probability:
				grid[i][j].set_plant(randi_range(1, 14))

func allows_window(i, j) -> bool:
	if grid[i][j].balcony:
		return false
	if i%floor_height != 1:
		return false
	
	return true

func allows_hole(i, j) -> bool:
	if grid[i][j].balcony:
		return false
	
	return true

func allows_plant(i, j) -> bool:
	if grid[i][j].balcony:
		return false
	
	return true

func generate_trap_doors() -> void:
	for j in size.x:
		if grid[0][j].is_decorated or grid[0][j].is_empty:
			continue
		if j > 0 and grid[0][j-1].is_trap_door:
			continue
		if randf() < trap_door_probability:
			grid[0][j].set_trap_door()
	
	for j in size.x:
		if grid[size.y-1][j].is_decorated or grid[size.y-1][j].is_empty:
			continue
		if j > 0 and grid[size.y-1][j-1].is_trap_door:
			continue
		if randf() < trap_door_probability:
			grid[size.y-1][j].set_trap_door()
	
func generate_balkony() -> void:
	if not is_left_border and not is_right_border:
		return
	if is_left_border and is_right_border:
		return
	var tmp_grid = []
	for i in size.y:
		tmp_grid.append([])
		if is_left_border:
			var tile_instance = Building_Tile.new()
			tmp_grid[i].append(tile_instance)
		for j in size.x:
			tmp_grid[i].append(grid[i][j])
		if is_right_border:
			var tile_instance = Building_Tile.new()
			tmp_grid[i].append(tile_instance)
	
	size.x += 1
	
	for i in size.y:
		if i%floor_height != 0:
			continue
		if is_left_border:
			if tmp_grid[i+1][1].slope or tmp_grid[i+2][1].slope:
				continue
			if randf() < balcony_probability:
				tmp_grid[i+1][0].set_balcony(1)
		else:
			if tmp_grid[i+1][size.x-2].slope or tmp_grid[i+2][size.x-2].slope:
				continue
			if randf() < balcony_probability:
				tmp_grid[i+1][size.x-1].set_balcony(4)
	
	grid = tmp_grid
