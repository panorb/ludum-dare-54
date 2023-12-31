extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_area: Area2D = $Area

signal self_clicked
signal wizard_clicked

var speaking = false
var error_texts = {}

func _ready():
	var error_texts_str = FileAccess.get_file_as_string("res://game/cards/speech_texts.json")
	self.error_texts = JSON.parse_string(error_texts_str)
	deactivate()
	tutorial()

func tutorial():
	var texts_str = FileAccess.get_file_as_string("res://gui/tutorial/tutorial_texts.json")
	var texts = JSON.parse_string(texts_str)["tutorial"]
	for text in texts:
		await self.speek(text, true)
		$TutorialTimer.start()
		await $TutorialTimer.timeout

func activate():
	animation_player.play("active")

func deactivate():
	animation_player.play("inactive")

func click_anywhere():
	self_clicked.emit()

func say_error(error_msg):
	self.speek(self.error_texts[error_msg])

func speek(text, await_click=false):
	self.speaking = true
	$SpeechBubble/Label.set_text(text)
	$SpeechBubble.show()
	$SpeechBubble/Timer.start()
	if await_click:
		var click = self_clicked
		await click
	else:
		await $SpeechBubble/Timer.timeout
	$SpeechBubble.hide()
	self.speaking = false

func _on_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_released() and event.button_index not in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		if not self.speaking:
			self.speek(self.error_texts["wizard_click"])
		wizard_clicked.emit()
