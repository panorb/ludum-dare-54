extends Node

@onready var start_button : BaseButton = %StartButton
@onready var sound_slider : HSlider = %SoundSlider
@onready var credits_button : BaseButton = %CreditsButton
@onready var quite_button : BaseButton = %QuitButton 

@onready var master_bus_index : int = AudioServer.get_bus_index('Master')

signal start_game
signal show_credits

func _ready():
	start_button.pressed.connect(self._start_button_pressed)
	quite_button.pressed.connect(self._quit_button_pressed)
	sound_slider.value_changed.connect(self._sound_value_changed)

func _start_button_pressed():
	self.start_game.emit()

func _credits_button_pressed():
	self.show_credits.emit()

func _quit_button_pressed():
	get_tree().quit()

func _sound_value_changed(volume_value: float):
	AudioServer.set_bus_volume_db (master_bus_index, volume_value)
