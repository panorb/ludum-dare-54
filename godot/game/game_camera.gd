extends Camera2D

const PIXELS_PER_PIXEL = 3
# Called when the node enters the scene tree for the first time.
func _ready():
	zoom = Vector2(PIXELS_PER_PIXEL, PIXELS_PER_PIXEL)
