extends Control

## Emitted when the letter is closed.
signal close

@onready var scroll_container = %ScrollContainer

var _texts = {}

func _ready() -> void:
	var texts_str = FileAccess.get_file_as_string("res://gui/letter/letter_texts.json")
	_texts = JSON.parse_string(texts_str)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("close_letter"):
		_on_close()

## Shows letter that will be extracted from [code]letter_texts.json[/code] by key [param text_key].
func show_letter(text_key: String, parameter := []) -> void:
	show()
	_set_text(text_key, parameter)
	%LetterText.scroll_to_line(0)
	get_tree().paused = true

func _on_close() -> void:
	hide()
	get_tree().paused = false
	emit_signal("close")

func _set_text(text_name: String, parameter: Array) -> void:
	var text: String = _texts[text_name] if _texts.has(text_name) else "Error: text %s not found." % text_name
	%LetterText.set_text(text % parameter)
