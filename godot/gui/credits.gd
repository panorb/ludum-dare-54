extends Control

@onready var close_button : BaseButton = %CloseButton 

# Called when the node enters the scene tree for the first time.
func _ready():
	close_button.pressed.connect(self._on_close_button_pressed)

func _on_close_button_pressed():
	pass
