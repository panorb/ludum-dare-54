extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	get_child(0).material.set_shader_parameter("u_progress", 10.)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
