@tool # also execute in editor to provide a preview
extends Node2D

@export var tilemap: TileMap
@export var draw_debug: bool = false
# outside buildings vary between the tile the origin of this node is inside and this side
@export var max_inside_size_variation: int = 1
@export var building_padding_on_outside: int = 40

@export var min_distance_between_patterns: int = 15
@export var min_template_height: int = 10
@export_range(0.0,1.0) var pattern_probability_per_row: float = 0.1

#@export var building_manager : BuildingManager

var tilemap_layer = 0
var tilemap_sourceid = 0

@export var fill_tile_id: Vector2i = Vector2i(1,4)

var random = RandomNumberGenerator.new()


var tilemap_starting_position: Vector2i

signal tower_spam(position:Vector2i)

# Called when the node enters the scene tree for the first time.
func _ready():
	if tilemap == null:
		printerr("tilemap is null @ ", get_stack());
		return;
		
	var global_coords = self.position;
	global_coords.y -= 1;
	var tilemap_local_coords = tilemap.to_local(global_coords);
	tilemap_starting_position = tilemap.local_to_map(tilemap_local_coords);

	if Engine.is_editor_hint():
		return
	
	#add_rows_if_needed(50);

	
var current_completed_row = 0
func _process(delta):
	if Engine.is_editor_hint() && draw_debug:
		_ready();
		queue_redraw();
	
	if Engine.is_editor_hint():
		return;
	add_rows_if_needed(10);

var current_row_width_delta = 0.0


func find_baseplate_start(pattern: TileMapPattern):
	var start = null

#	print(pattern.get_size())
	for y in range(pattern.get_size().y-1, -1, -1):
		for x in range(pattern.get_size().x):
			if pattern.has_cell(Vector2i(x,y)):
				# we found a tile, this'll serve as the start
				return Vector2i(x,y);
	return null;

func calculate_pattern_baseplate_middle_offset(pattern: TileMapPattern):
	var start = find_baseplate_start(pattern);
	if start == null:
		return null;
	
	var end = null;
	for x in range(start.x, pattern.get_size().x):
		if not pattern.has_cell(Vector2i(x, start.y)):
			end = Vector2i(x-1, start.y);
			break;

	if end == null:
		end = Vector2i(pattern.get_size().x-1, start.y);
	
	var middle = Vector2i(start.x + (end.x - start.x) / 2, start.y);
	return middle;


var last_pattern_used_at_height = null

func add_rows_if_needed(amount_to_draw: int):
	if current_completed_row < 10000 && fill_tile_id != null && tilemap != null:
		var row = current_completed_row

		var orig_completed_row = current_completed_row

		while row < orig_completed_row + amount_to_draw:
			var previous_row_width_delta = current_row_width_delta;
			current_row_width_delta = get_row_width(row, current_row_width_delta);
			var direction = 1
			if max_inside_size_variation < 0:
				direction = -1
			for x in range(-building_padding_on_outside, floorf(current_row_width_delta), direction):
				# fill with
				tilemap.set_cell(tilemap_layer, tilemap_starting_position + Vector2i(x, -row), tilemap_sourceid, fill_tile_id);
				tower_spam.emit(tilemap_starting_position + Vector2i(x, -row))
			
			var fix_tile_position = null
			var tile_type = Vector2i(1,4)
			if current_row_width_delta > previous_row_width_delta:
				# we're getting wider, add a angular tile
				if max_inside_size_variation > 0:
					fix_tile_position = Vector2i(floorf(current_row_width_delta) - 1, -row + 1);
					tile_type = Vector2i(2,15)
				else:
					fix_tile_position = Vector2i(ceilf(current_row_width_delta), -row + 1);
					tile_type = Vector2i(0,14)
				
			elif current_row_width_delta < previous_row_width_delta:
				# we're getting narrower, add a angular tile
				if max_inside_size_variation > 0:
					fix_tile_position = Vector2i(floorf(current_row_width_delta), -row);
					tile_type = Vector2i(2,14)
				else:
					fix_tile_position = Vector2i(ceilf(current_row_width_delta), -row);
					tile_type = Vector2i(0,15)
			
			if fix_tile_position != null:
				tilemap.set_cell(tilemap_layer, tilemap_starting_position + fix_tile_position, tilemap_sourceid, tile_type);
				tower_spam.emit(tilemap_starting_position + Vector2i(fix_tile_position.x, -row))
			row += 1;
			current_completed_row += 1;
			
			if random.randf() < pattern_probability_per_row && ((last_pattern_used_at_height == null && row >= min_template_height) || 
					(last_pattern_used_at_height != null && row >= last_pattern_used_at_height + min_distance_between_patterns)):
				# add pattern
				var pattern_id = random.randi_range(0, self.tilemap.tile_set.get_patterns_count()-1);
				var pattern_to_place = self.tilemap.tile_set.get_pattern(pattern_id);
				var pattern_height = pattern_to_place.get_size().y;
				var pattern_position = self.tilemap_starting_position + Vector2i(0, -row);
				var offset = calculate_pattern_baseplate_middle_offset(pattern_to_place);
				if offset == null:
					print("could not find offset for pattern");
					return;
				self.tilemap.set_pattern(0, pattern_position - offset, pattern_to_place);
				for y in range(pattern_to_place.get_size().y):
					for x in range(pattern_to_place.get_size().x):
						if pattern_to_place.has_cell(Vector2i(x, y)):
							tower_spam.emit(Vector2i(x, y)+pattern_position - offset)
				row += pattern_height;
				last_pattern_used_at_height = row
				current_completed_row += pattern_height;

		if current_completed_row >= 10000:
			print("done creating secondary buildings");
			return;


func get_row_width(current_row:int, last_row_width_delta:float):
	var total_variance = max_inside_size_variation;

	var this_row_delta = (-1.0 *cos(1.0/45.0 * current_row * PI)) * total_variance/2.0 + total_variance/2.0;

		
	# make sure we don't go too far / too close
	if max_inside_size_variation > 0:
		this_row_delta = round(clamp(this_row_delta, 0, max_inside_size_variation))
	else:
		this_row_delta = round(clamp(this_row_delta, max_inside_size_variation, 0))


	return this_row_delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	if not draw_debug:
		return;
	# provide in editor debug drawings
	if tilemap != null:
		self._highlight_rect(tilemap_starting_position, Color.GREEN, 2);

		# draw max inset tile
		self._highlight_rect(tilemap_starting_position + Vector2i(max_inside_size_variation, 0), Color.RED, 2);
		self._highlight_rect(tilemap_starting_position + Vector2i(-building_padding_on_outside, 0), Color.CYAN, 2);


func _highlight_rect(tilemap_coords: Vector2i, color: Color = Color.CYAN, width: int = 1, fill: bool = false):
	var local = tilemap.map_to_local(tilemap_coords);
	var global = tilemap.to_global(local);
	var local_to_self = self.to_local(global);
	local_to_self.x -= 8;
	local_to_self.y -= 8;
	var rect = Rect2(local_to_self, Vector2(16,16));
	if fill:
		draw_rect(rect, color, true);
	else:
		draw_rect(rect, color, false, width);


