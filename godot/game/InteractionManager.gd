extends Node2D

@export var camera: Camera2D
@export var camera_sensitivity: float = 5.0
@export var drag_start_time: int = 150
@export var bgsTimer: float = 0.
@onready var _letter := get_node("%Letter")

signal primary_interaction_just_pressed_sig

const MOUSE_SCROLL_SPEED: int = 10

func _process(delta: float) -> void:
	if _letter.visible:
		return

	var movement = 0;

	if Input.is_action_pressed("camera_up"):
		movement -= 1

	if Input.is_action_pressed("camera_down"):
		movement += 1

	if Input.is_action_just_released("camera_wheel_up"):
		movement -= MOUSE_SCROLL_SPEED

	if Input.is_action_just_released("camera_wheel_down"):
		movement += MOUSE_SCROLL_SPEED

	camera.position.y += movement * camera_sensitivity * delta * 100
	camera.position.y = min(0, camera.position.y)

	var background_scene = get_parent().get_parent().get_node("Background")
	#if background_scene:
	var color_rect = background_scene.get_node("SubViewport").get_child(0).get_child(0)
	bgsTimer += delta
	color_rect.material.set_shader_parameter("u_startAnim", 1.)#minf(smoothstep(0.,1.,bgsTimer),1.))
	var prog = maxf(-1.01,-.01-camera.get_screen_center_position().y/50000.) #TODO 50k seems reasonable
	color_rect.material.set_shader_parameter("u_progress", prog)
	color_rect.material.set_shader_parameter("u_perspective", .2)

	if Input.is_action_just_released("primary_action"):
		if current_state == MOUSE_STATE.CLICKING:
			primary_interaction_just_pressed_sig.emit()
		current_state = MOUSE_STATE.INACTIVE
		starting_position = null
		primary_pressed = false

enum MOUSE_STATE { INACTIVE, DRAGGING, CLICKING}
var current_state = MOUSE_STATE.INACTIVE
var starting_position = null
var primary_pressed = false
func _input(event: InputEvent) -> void:
	if _letter.visible:
		return

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
			else:
				starting_position = event.position
	if event is InputEventMouseMotion:
		if current_state == MOUSE_STATE.DRAGGING:
			camera.position.y -= event.relative.y * camera_sensitivity * 0.8
			camera.position.y = min(0, camera.position.y)
