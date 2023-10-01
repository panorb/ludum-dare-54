extends Node


signal start_game
signal show_credits

@export var start_volume : float = 70

@onready var start_button : BaseButton = %StartButton
@onready var sound_slider : HSlider = %SoundSlider
@onready var sound_percent_label : Label = %SoundPercentLabel
@onready var credits_button : BaseButton = %CreditsButton
@onready var quite_button : BaseButton = %QuitButton 
@onready var master_bus_index : int = AudioServer.get_bus_index('Master')


func _ready() -> void:
	start_button.pressed.connect(self._on_StartButton_pressed)
	quite_button.pressed.connect(self._on_QuitButton_pressed)
	sound_slider.value_changed.connect(self._on_SoundSlider_value_changed)
	
	sound_slider.value = self.start_volume


func _on_StartButton_pressed() -> void:
	self.start_game.emit()


func _on_CreditsButton_pressed() -> void:
	self.show_credits.emit()


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_SoundSlider_value_changed(volume_value: float) -> void:
	AudioServer.set_bus_volume_db (master_bus_index, volume_value)
	sound_percent_label.text = str(volume_value) +"%"
