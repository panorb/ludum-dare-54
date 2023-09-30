extends Node2D


@export var camera: Camera2D
@export var camera_sensitivity: float = 1.0
@export_range(0.0,1.0) var camera_acceleration: float = 0.25
@export var drag_start_time: int = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

var current_cam_speed = Vector2(0, 0);

# for delayed drag
var starting_time = 0
var drag_enabled = false

func _process(delta):


	var movement = 0;

	if Input.is_action_pressed("camera_up"):
		movement -= 1
	
	if Input.is_action_pressed("camera_down"):
		movement += 1

	current_cam_speed.y = lerpf(current_cam_speed.y, movement, 0.25)
	camera.position.y += current_cam_speed.y * camera_sensitivity * delta * 100

	if Input.is_action_pressed("primary_action"):
		if starting_time == null:
			starting_time = Time.get_ticks_msec()
		else:
			if Time.get_ticks_msec() - starting_time > drag_start_time && !drag_enabled:
				drag_enabled = true
				print_debug("drag enabled")
	elif Input.is_action_just_released("primary_action"):
		drag_enabled = false
		print_debug("drag disabled")


func _input(event):
	if event is InputEventMouseMotion:
		if drag_enabled:
			camera.position.y -= event.relative.y


