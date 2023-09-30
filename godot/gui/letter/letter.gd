extends Control

## Emitted when the letter is closed.
signal close

var _texts = {}

func _ready() -> void:
	var texts_str = FileAccess.get_file_as_string("res://gui/letter/letter_texts.json")
	_texts = JSON.parse_string(texts_str)
	#show_letter("start")

func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		_on_close()

## Shows letter that will be extracted from [code]letter_texts.json[/code] by key [param text_key].
func show_letter(text_key: String) -> void:
	show()
	_set_text(text_key)

func _on_close() -> void:
	hide()
	emit_signal("close")

func _set_text(text_name: String) -> void:
	var text: String = _texts[text_name] if _texts.has(text_name) else "Error: text %s not found." % text_name
	%LetterText.set_text(text)
