extends Node2D

@export var tileMap: TileMap = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_interaction_manager_primary_interaction_just_pressed_sig():
	var local_coordinates = get_local_mouse_position()
	if tileMap != null:
		var tilemap_coords = tileMap.local_to_map(local_coordinates)
		print("Tilemap coords clicked @ " + str(tilemap_coords))
