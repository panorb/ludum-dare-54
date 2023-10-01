@tool # also execute in editor to provide a preview
extends Node2D

@export var tilemap: TileMap
@export var draw_debug: bool = false
# outside buildings vary between the tile the origin of this node is inside and this side
@export var outside_building_side: int = 1
@export var building_padding_on_outside: int = 40


var tilemap_layer = 0
var tilemap_sourceid = 0

@export var fill_tile_id: Vector2i = Vector2i(1,4)


var tilemap_starting_position: Vector2i

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
	
	add_rows_if_needed(50);

	
var current_completed_row = 0
func _process(delta):
	if Engine.is_editor_hint() && draw_debug:
		_ready();
		queue_redraw();
		return;
	
	add_rows_if_needed(10);

func add_rows_if_needed(amount_to_draw: int):
	if current_completed_row < 10000 && fill_tile_id != null && tilemap != null:
		if outside_building_side < 0:
			for row in range(current_completed_row, current_completed_row + amount_to_draw):
				for x in range(0, -outside_building_side - building_padding_on_outside):
					# fill with
					tilemap.set_cell(tilemap_layer, tilemap_starting_position + Vector2i(x, -row), tilemap_sourceid, fill_tile_id);
		else:
			for row in range(current_completed_row, current_completed_row + amount_to_draw):
				for x in range(0, outside_building_side + building_padding_on_outside - 1):
					# fill with
					tilemap.set_cell(tilemap_layer, tilemap_starting_position + Vector2i(-x, -row), tilemap_sourceid, fill_tile_id);
		current_completed_row += amount_to_draw;
		if current_completed_row >= 10000:
			print("done creating secondary buildings");
			return;
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	if not draw_debug:
		return;
	# provide in editor debug drawings
	if tilemap != null:
		self._highlight_rect(tilemap_starting_position, Color.GREEN, 2);

		# draw max inset tile
		self._highlight_rect(tilemap_starting_position + Vector2i(outside_building_side, 0), Color.RED, 2);
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


