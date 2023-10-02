extends Control


var volume_mute_image := preload("res://gui/volume_mute.png")
var volume_25_image := preload("res://gui/volume_25.png")
var volume_50_image := preload("res://gui/volume_50.png")
var volume_75_image := preload("res://gui/volume_75.png")
var volume_full_image := preload("res://gui/volume_full.png")

@onready var continue_button := %ContinueButton
@onready var sound_image := %SoundImage
@onready var sound_slider : HSlider = %SoundSlider
@onready var sound_percent_label : Label = %SoundPercentLabel
@onready var quit_button : BaseButton = %QuitButton
@onready var master_bus_index : int = AudioServer.get_bus_index('Master')


func _ready() -> void:
	continue_button.pressed.connect(self._on_ContinueButton_pressed)
	quit_button.pressed.connect(self._on_QuitButton_pressed)
	sound_slider.value_changed.connect(self._on_SoundSlider_value_changed)

	if OS.get_name() == 'Web':
		quit_button.visible = false

	sound_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_index)) * 100


func _on_ContinueButton_pressed() -> void:
	SceneManager.show_scene("game")


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_SoundSlider_value_changed(volume_value: float) -> void:
	AudioServer.set_bus_volume_db (master_bus_index, linear_to_db(volume_value / 100))
	sound_percent_label.text = str(volume_value) +"%"

	if volume_value <= 0 :
		sound_image.texture = volume_mute_image
	elif volume_value > 0 && volume_value <=25:
		sound_image.texture = volume_25_image
	elif volume_value > 25 && volume_value <=50:
		sound_image.texture = volume_50_image
	elif volume_value > 50 && volume_value <=75:
		sound_image.texture = volume_75_image
	elif volume_value > 75 && volume_value <=100:
		sound_image.texture = volume_full_image
