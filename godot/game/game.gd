extends Node2D


@export var camera: Camera2D
@export var camera_sensitivity: float = 1.0
@export var drag_start_time: int = 150

# for delayed drag
var starting_time : int = 0
var drag_enabled := false


func _process(delta: float) -> void:
	var movement : int = 0

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


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if drag_enabled:
			camera.position.y -= event.relative.y * 3
			camera.position.y = min(0, camera.position.y)
