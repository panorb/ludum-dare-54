extends Node2D

signal card_hand_ready

@export var card_scene : PackedScene = preload("res://game/cards/card.tscn")
@export_range(1, 6) var card_num : int = 3 
@export_range(5, 75) var card_spacing : int = 5
@export_range(-75, 75) var y_offset : int = -45

var hand_cards : Array[Card] = []
var held_card : Card = null

func _ready() -> void:
	get_tree().get_root().size_changed.connect(reorganize_hand)
	initial_card_draw()


func initial_card_draw() -> void:
	for i in 3:
		draw_card()
	
	reorganize_hand()
	
	self.card_hand_ready.emit()

func draw_card() -> void:
	var y = get_viewport_rect().size.y + 120
	var x = get_viewport_rect().size.x / 2
	
	var card_instance : Card = card_scene.instantiate()
	card_instance.hover_begin.connect(self._on_Card_hover_begin)
	card_instance.hover_end.connect(self._on_Card_hover_end)
	card_instance.selected.connect(self._on_Card_selected)
	card_instance.position.x = x
	card_instance.position.y = y
	
	add_child(card_instance)
	hand_cards.append(card_instance)

func _on_Card_hover_begin(card : Card) -> void:
	if held_card and card != held_card and held_card.is_hovered:
		return
	
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
			held_card = null
			hand_cards.append(card)
		else:
			hand_cards = hand_cards.filter(func(elem : Card): return elem.name != card.name)
			hand_cards.append(held_card)
			held_card = card
	else:
		card.select()
		hand_cards = hand_cards.filter(func(elem : Card): return elem.name != card.name)
		held_card = card
	
	# draw_card()
	reorganize_hand()

func reorganize_hand() -> void:
	var card_num : int = len(hand_cards)
	if not card_num:
		return
		
	var tween : Tween = create_tween()
	tween.set_parallel()
	
	if held_card:
		var held_y = get_viewport_rect().size.y + y_offset - 20
		var held_x = get_viewport_rect().size.x / 2.0
		tween.tween_property(held_card, "position", Vector2(held_x, held_y), 0.6)
		
	var spacer_num: int = card_num - 1
	var total_width: int = card_num * hand_cards[0].texture.get_width()
	total_width += spacer_num * card_spacing
	var half_width: int = total_width / 2.0
	
	var start_x = (get_viewport_rect().size.x / 2.0) - half_width + (hand_cards[0].texture.get_width() / 2.0)
	$StartX.position = Vector2(start_x, 40)
	
	# var start_x = (get_viewport_rect().size.x / 2.0) - ((card_num / 2.0) * (hand_cards[0].texture.get_width() + card_spacing))
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


