extends Node2D


@export var camera: Camera2D
@export var camera_sensitivity: float = 1.0
@export var drag_start_time: int = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

# for delayed drag
var starting_time = 0
var drag_enabled = false

func _process(delta):


	var movement = 0;

	if Input.is_action_pressed("camera_up"):
		movement -= 1
	
	if Input.is_action_pressed("camera_down"):
		movement += 1

	camera.position.y += movement * camera_sensitivity * delta * 100
	camera.position.y = min(0, camera.position.y)

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
			camera.position.y = min(0, camera.position.y)


