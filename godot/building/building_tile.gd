class_name Building_Tile extends Node

@export var full_capacity = 1.0
@export var slope_capacity = 0.5
@export var roof_deduction = 0.2
@export var hole_deduction = 0.1
@export var window_deduction = -0.1

var is_empty : bool = true
var is_scaffold : bool = false
var is_top : bool = false
var is_bottom : bool = false
var is_trap_door : bool = false
var balcony : int = 0
var window : int = 0
var color : int = 0
var roof : int = 0
var hole : int = 0
var plant : int = 0
var is_golden : bool = false
var is_door : bool = false
var slope : int = 0
var left_right_edge : int = 0
var tile := Vector2i(-1, -1)
var tile_decoration := Vector2i(-1, -1)
var is_decorated : bool = false
var door : int = 0
var is_support : bool = false

var tile_capacity : float = 0

func set_golden() -> void:
	is_golden = true
	is_decorated = true
	update_tile()

func set_support() -> void:
	is_support = true
	is_decorated = true
	update_tile()

func set_brick(number) -> void:
	is_empty = false
	color = number
	update_tile()

func set_door(number) -> void:
	door = number
	is_decorated = true
	update_tile()

func set_scaffold() -> void:
	is_empty = false
	is_scaffold = true
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

func set_balcony(number) -> void:
	balcony = number
	is_empty = false
	update_tile()

func update_tile() -> void:
	tile_capacity = 0.0
	
	if not self.is_empty and not self.balcony and not self.is_scaffold:
		tile_capacity += full_capacity
		
		tile = Vector2i(13, 5+4*color)
		if self.left_right_edge == 1:
			tile.x -= 1
		if self.left_right_edge == 2:
			tile.x += 1
		if self.is_top:
			tile.y -= 1
		if self.is_bottom:
			tile.y += 1
			if self.is_support and not self.is_scaffold:
				tile.y += 1
		
	else:
		tile = Vector2i(-1, -1)
		if self.slope:
			tile_capacity += slope_capacity
			tile = Vector2i(10, 5+4*color)
			if slope == 2 or slope == 4:
				tile.x += 1
			if slope == 3 or slope == 4:
				tile.y += 1
	
	if self.is_scaffold:
		tile = Vector2i(15, 8)
		if is_top:
			tile.y -= 1
		if is_bottom:
			tile.y += 1
	
	if roof:
		tile_capacity -= roof_deduction
		tile = Vector2i(13, 0+(roof-1))
		if slope == 1:
			tile.x -= 1
		if slope == 2:
			tile.x += 1
	
	if hole:
		tile_capacity -= hole_deduction
		tile_decoration = Vector2i(6+(hole-1)/3, 7+(hole-1)%3)
	
	if plant:
		tile_decoration = Vector2i(6+(plant-1)/4, 10+(plant-1)%4)
	
	if window:
		tile_capacity -= window_deduction
		tile_decoration = Vector2i(3+(window-1)/3, 9+(window-1)%3)
	
	if is_trap_door:
		if is_top:
			if roof:
				tile.x += 2
				tile_decoration = Vector2i(-1, -1)
			else:
				tile_decoration = Vector2i(3, 8)
		elif is_bottom:
			tile_decoration = Vector2i(3, 7)
	
	if is_golden:
		tile_decoration = Vector2i(9, 12)
	
	if balcony:
		tile = Vector2i(15, 9 + balcony)
	
	if door:
		tile_decoration = Vector2i(3+(door-1)%3, 5+(door-1)/3)
