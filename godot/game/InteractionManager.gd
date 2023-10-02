extends Node2D

class_name  InteractionManager

@export var camera: Camera2D
@export var camera_sensitivity: float = 5.0
@export var drag_start_time: int = 150
@export var bgsTimer: float = 0.
@export var tower: Tower
@onready var _letter := get_node("%Letter")

var limit = true

signal primary_interaction_just_pressed_sig
signal player_height_changed(player_height: float)


const MOUSE_SCROLL_SPEED: int = 10
var _windscrolling := false
var _duration := 0.0

func sigmoid(x: float) -> float:
	return 1. / (1. + exp(-x))

func _process(delta: float) -> void:
	if _letter.visible:
		return

	var movement: int = 0;

	if Input.is_action_pressed("camera_up"):
		movement -= 1

	if Input.is_action_pressed("camera_down"):
		movement += 1

	if Input.is_action_just_released("camera_wheel_up"):
		movement -= MOUSE_SCROLL_SPEED

	if Input.is_action_just_released("camera_wheel_down"):
		movement += MOUSE_SCROLL_SPEED

	_duration += delta
	if (movement == 0 && _windscrolling || movement != 0 && !_windscrolling) && _duration > 1.:
		_windscrolling = !_windscrolling
		_duration = 0.0
		$WindscrollSound.play()

	camera.position.y += movement * camera_sensitivity * delta * 100
	var height = tower.height * (-16)
	if height == null:
		height = 3 * (-16)
	if limit:
		camera.position.y = clamp(camera.position.y, height + (3 * -16), 0)
	else:
		camera.position.y = min(camera.position.y, 0)
	self.player_height_changed.emit(absf(camera.position.y))

	var background_scene = get_parent().get_parent().get_node("Background")
	#if background_scene:
	var color_rect = background_scene.get_node("SubViewport").get_child(0).get_child(0)
	bgsTimer += delta
	color_rect.material.set_shader_parameter("u_startAnim", 1.)#minf(smoothstep(0.,1.,bgsTimer),1.))
	var prog = -.01-camera.get_screen_center_position().y/5000. #TODO 50k seems reasonable
	if prog > 1.5:
		prog = 1 + sigmoid(prog-1.5)
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
			var height = tower.height * (-16)
			if height == null:
				height = 3 * (-16)
			if limit:
				camera.position.y = clamp(camera.position.y, height + (3 * -16), 0)
			else:
				camera.position.y = min(camera.position.y, 0)
	self.player_height_changed.emit(absf(camera.position.y))
