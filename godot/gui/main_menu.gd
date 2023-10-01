extends Node


signal start_game
signal show_credits

@export var start_volume : float = 70

@onready var start_button : BaseButton = %StartButton
@onready var sound_slider : HSlider = %SoundSlider
@onready var sound_percent_label : Label = %SoundPercentLabel
@onready var credits_button : BaseButton = %CreditsButton
@onready var quit_button : BaseButton = %QuitButton
@onready var master_bus_index : int = AudioServer.get_bus_index('Master')


func _ready() -> void:
	start_button.pressed.connect(self._on_StartButton_pressed)
	quit_button.pressed.connect(self._on_QuitButton_pressed)
	credits_button.pressed.connect(self._on_CreditsButton_pressed)
	sound_slider.value_changed.connect(self._on_SoundSlider_value_changed)

	if OS.get_name() == 'Web':
		quit_button.visible = false

	sound_slider.value = self.start_volume
	
	var background_scene = get_node("background")
	#if background_scene:
	var color_rect = background_scene.get_node("CanvasLayer").get_child(0)
	color_rect.material.set_shader_parameter("u_startAnim", 0.)
	var prog = -.01
	color_rect.material.set_shader_parameter("u_progress", prog)
	color_rect.material.set_shader_parameter("u_perspective", .2)

func _on_StartButton_pressed() -> void:
	self.start_game.emit()
	SceneManager.show_scene("game")


func _on_CreditsButton_pressed() -> void:
	self.show_credits.emit()
	SceneManager.show_scene("credits")


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_SoundSlider_value_changed(volume_value: float) -> void:
	AudioServer.set_bus_volume_db (master_bus_index, volume_value)
	sound_percent_label.text = str(volume_value) +"%"
