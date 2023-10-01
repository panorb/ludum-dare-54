extends Control

@onready var close_button : BaseButton = %CloseButton 

# Called when the node enters the scene tree for the first time.
func _ready():
	close_button.pressed.connect(self._on_CloseButton_pressed)

func _on_CloseButton_pressed():
	SceneManager.show_scene("main_menu")
