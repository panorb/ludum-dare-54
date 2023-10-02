extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	deactivate()

func activate():
	animation_player.play("active")

func deactivate():
	animation_player.play("inactive")

func speek(text):
	$SpeechBubble/Label.set_text(text)
	$SpeechBubble.show()
	$SpeechBubble/Timer.start()
	await $SpeechBubble/Timer.timeout
	$SpeechBubble.hide()
