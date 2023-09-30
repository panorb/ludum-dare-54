extends Node2D


@export var camera: Camera2D
@export var camera_sensitivity: float = 1.0
@export_range(0.0,1.0) var camera_acceleration: float = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

var current_cam_speed = Vector2(0, 0);
func _process(delta):


	var movement = 0;

	if Input.is_action_pressed("camera_up"):
		movement += 1
	
	if Input.is_action_pressed("camera_down"):
		movement -= 1

	current_cam_speed.y = lerpf(current_cam_speed.y, movement, 0.25)
	camera.position.y += current_cam_speed.y * camera_sensitivity * delta * 100



