extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_area: Area2D = $Area

signal self_clicked
signal wizard_clicked

var speaking = false

func _ready():
	deactivate()
	tutorial()

func tutorial():
#	var click = clicked
#	await click
	var texts_str = FileAccess.get_file_as_string("res://gui/tutorial/tutorial_texts.json")
	var texts = JSON.parse_string(texts_str)["tutorial"]
	for text in texts:
		await self.speek(text, true)
		$TutorialTimer.start()
		await $TutorialTimer.timeout
#		await self.speek("bar", true)
#		$TutorialTimer.start()
#		await $TutorialTimer.timeout
#		await self.speek("baz", true)

func activate():
	animation_player.play("active")

func deactivate():
	animation_player.play("inactive")

func click_anywhere():
	self_clicked.emit()

func speek(text, await_click=false):
	print("speaking now")
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
		print(self.speaking)
		if not self.speaking:
			self.speek("That's me!")
		wizard_clicked.emit()
