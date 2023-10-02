extends Node2D

signal card_hand_ready
signal card_selected(card:Card)
signal card_deselected
signal wizard_clicked

@export var card_scene : PackedScene = preload("res://game/cards/card.tscn")
@export_range(1, 6) var card_num : int = 3 
@export_range(5, 75) var card_spacing : int = 5
@export_range(-150, 75) var y_offset : int = -120

@onready var card_wizard = $CardWizard

@onready var select_sound := %SelectSound

var hand_cards : Array[Card] = []
var held_card : Card = null:
	set(value):
		if held_card != value:
			play_select_sound()
		held_card = value

var select_sounds := [preload("res://game/cards/sparkle_1.wav"), preload("res://game/cards/sparkle_2.wav")]
var playing_select_sound_index := 0

func _ready() -> void:
	# get_tree().get_root().size_changed.connect(reorganize_hand)
	initial_card_draw()

func initial_card_draw() -> void:
	draw_card(Card.CardType.CARD_TYPE_NORMAL, 4)
	draw_card(Card.CardType.CARD_TYPE_SCAFFOLD, 1)
	
	self.card_hand_ready.emit()

func draw_card(card_type := Card.CardType.CARD_TYPE_NORMAL, count: int = 0) -> void:
	for i in range(count):
		var y = get_viewport_rect().size.y + 200
		var x = get_viewport_rect().size.x / 2
		
		
		var card_instance : Card = card_scene.instantiate()
		
		card_instance.hover_begin.connect(self._on_Card_hover_begin)
		card_instance.hover_end.connect(self._on_Card_hover_end)
		card_instance.selected.connect(self._on_Card_selected)
		card_instance.position.x = x
		card_instance.position.y = y
		# card_instance.init_capacity(0)
		
		add_child(card_instance)
		
		card_instance.init(card_type)
		hand_cards.append(card_instance)
	reorganize_hand()

func drop_card():
	if held_card == null:
		return
	held_card.queue_free()
	held_card = null
	card_wizard.deactivate()

func _on_Card_hover_begin(card : Card) -> void:
	if held_card and card != held_card and held_card.is_hovered:
		return
	
	if card == held_card:
		for hand_card in hand_cards:
			hand_card.blur()
	
	card.focus()

func _on_Card_hover_end(card : Card) -> void:
	card.blur()
	
	if card == held_card:
		for hand_card in hand_cards:
			if hand_card.is_hovered:
				hand_card.focus()

func _on_Card_selected(card : Card) -> void:
	if held_card:
		held_card.deselect()
		if held_card == card:
			card_wizard.deactivate()
			held_card = null
			hand_cards.append(card)
			card_deselected.emit()
		else:
			card.select()
			card_wizard.activate()
			hand_cards = hand_cards.filter(func(elem : Card): return elem.name != card.name)
			hand_cards.append(held_card)
			held_card = card
	else:
		card.select()
		card_wizard.activate()
		hand_cards = hand_cards.filter(func(elem : Card): return elem.name != card.name)
		held_card = card
	if held_card != null:
		card_selected.emit(held_card)
	
	reorganize_hand()

func reorganize_hand() -> void:
	var card_num : int = len(hand_cards)
	if not card_num:
		return
#
	var tween : Tween = create_tween()
	tween.set_parallel()
	
	if held_card:
		var held_y = get_viewport_rect().size.y + y_offset - 40
		var held_x = get_viewport_rect().size.x / 2.0
		tween.tween_property(held_card, "position", Vector2(held_x, held_y), 0.6)
		
	var spacer_num: int = card_num - 1
	var total_width: int = card_num * hand_cards[0].texture.get_width()
	total_width += spacer_num * card_spacing
	var half_width: int = total_width / 2.0
	
	var start_x = (get_viewport_rect().size.x / 2.0) - half_width + (hand_cards[0].texture.get_width() / 2.0)
	
	var y = get_viewport_rect().size.y + y_offset
	if held_card:
		y += 35
	
	for i in card_num:
		var card : Card = hand_cards[i]
		
		var x : int = start_x + (i * (card_spacing + hand_cards[0].texture.get_width()))
		var target_position : Vector2 = Vector2(x, y)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(card, "position", target_position, 0.6)
	
	tween.play()

func redraw():
	drop_card()
	for card in hand_cards:
		card.queue_free()
	hand_cards.clear()
	draw_card(Card.CardType.CARD_TYPE_NORMAL, 5)
	
func play_select_sound():
	var current_playing_select_sound_index = self.playing_select_sound_index % self.select_sounds.size()
	self.select_sound.stream = self.select_sounds[current_playing_select_sound_index]
	self.select_sound.play()
	self.playing_select_sound_index += 1

func speek(text):
	card_wizard.speek(text)

func click_anywhere():
#	pass
	self.card_wizard.click_anywhere()

#
#func _on_button_pressed():
#	self.card_wizard.click_anywhere()


func _on_card_wizard_wizard_clicked():
	wizard_clicked.emit()
