extends Node2D


@export var tilemap: TileMap
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("primary_action"):
		var mouse_pos = get_global_mouse_position()
		var local_coords = tilemap.to_local(mouse_pos)
		var tile_pos = tilemap.local_to_map(local_coords)
		print_debug(tile_pos)

