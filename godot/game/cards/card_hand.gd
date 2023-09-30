extends Node2D

signal card_hand_ready

@export var card_scene : PackedScene = preload("res://game/cards/card.tscn")
@export_range(5, 75) var card_spacing : int = 5
@export_range(-75, 75) var y_offset : int = -45

var hand_cards : Array[Card] = []
var held_card : Card = null

func _ready() -> void:
	initial_card_draw()

func initial_card_draw() -> void:
	for i in 12:
		draw_card()
	
	reorganize_hand()
	
	self.card_hand_ready.emit()

func draw_card() -> void:
	print("Drawing a card...")
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
	card.focus()

func _on_Card_hover_end(card : Card) -> void:
	card.blur()

func _on_Card_selected(card : Card) -> void:
	hand_cards = hand_cards.filter(func(elem : Card): return elem.name != card.name)
	held_card = card
	card.visible = false
	
	reorganize_hand()

func reorganize_hand() -> void:
	var card_num : int = len(hand_cards)
	if not card_num:
		return
	
	print("card_num: ", card_num)
	
	var spacer_num = card_num - 1
	var total_width = card_num * hand_cards[0].texture.get_width()
	total_width += spacer_num * card_spacing
	var half_width = total_width / 2.0
	
	var start_x = (get_viewport_rect().size.x / 2.0) - half_width + (hand_cards[0].texture.get_width() / 2.0)
	$StartX.position = Vector2(start_x, 40)
	
	
	# var start_x = (get_viewport_rect().size.x / 2.0) - ((card_num / 2.0) * (hand_cards[0].texture.get_width() + card_spacing))
	var y = get_viewport_rect().size.y + y_offset
	
	var tween : Tween = create_tween()
	tween.set_parallel()
	
	for i in card_num:
		var card : Card = hand_cards[i]
		
		var x : int = start_x + (i * (card_spacing + hand_cards[0].texture.get_width()))
		var target_position : Vector2 = Vector2(x, y)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(card, "position", target_position, 0.6)
	
	tween.play()


