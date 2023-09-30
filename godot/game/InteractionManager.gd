extends Node2D

@export var camera: Camera2D
@export var camera_sensitivity: float = 5.0
@export var drag_start_time: int = 150

signal primary_interaction_just_pressed_sig


func _process(delta):


	var movement = 0;

	if Input.is_action_pressed("camera_up"):
		movement -= 1
	
	if Input.is_action_pressed("camera_down"):
		movement += 1

	camera.position.y += movement * camera_sensitivity * delta * 100
	camera.position.y = min(0, camera.position.y)

	if Input.is_action_just_released("primary_action"):
		if current_state == MOUSE_STATE.CLICKING:
			primary_interaction_just_pressed_sig.emit()
			print_debug("clicked")
		current_state = MOUSE_STATE.INACTIVE
		starting_position = null
		primary_pressed = false

enum MOUSE_STATE { INACTIVE, DRAGGING, CLICKING}
var current_state = MOUSE_STATE.INACTIVE
var starting_position = null
var primary_pressed = false
func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("primary_action"):
			primary_pressed = true

	if event is InputEventMouse:
		if not primary_pressed:
			return;
		if current_state == MOUSE_STATE.INACTIVE:
			current_state = MOUSE_STATE.CLICKING
			starting_position = event.position
		elif current_state == MOUSE_STATE.CLICKING:
			if starting_position != null: 
				if starting_position.distance_to(event.position) > 5:
					current_state = MOUSE_STATE.DRAGGING
					print_debug("dragging")
			else:
				starting_position = event.position
	if event is InputEventMouseMotion:
		if current_state == MOUSE_STATE.DRAGGING:
			camera.position.y -= event.relative.y * camera_sensitivity * 0.8
			camera.position.y = min(0, camera.position.y)
