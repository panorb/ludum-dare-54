extends Node2D

signal card_hand_ready

@export var card_scene : PackedScene = preload("res://game/cards/card.tscn")
@export_range(5, 75) var card_spacing : int = 50
@export_range(-75, 75) var y_offset : int = -50

func _ready() -> void:
	initial_card_draw()

func initial_card_draw() -> void:
	draw_card()
	await self.get_tree().create_timer(1.0).timeout
	draw_card()
	await self.get_tree().create_timer(1.0).timeout
	draw_card()
	await self.get_tree().create_timer(0.4).timeout
	
	reorganize_hand()
	self.card_hand_ready.emit()

func draw_card() -> void:
	print("Drawing a card...")
	var card_num : int = get_child_count()
	print(get_viewport_rect().size)
	var y = get_viewport_rect().size.y + y_offset
	var x = ((get_viewport_rect().size.x / 2) - 30) + (30 * card_num)
	
	var card_instance : Card = card_scene.instantiate()
	#card_instance.position.x = x
	#card_instance.position.y = y
	
	add_child(card_instance)

func reorganize_hand() -> void:
	var card_num : int = get_child_count()
	var start_x = (get_viewport_rect().size.x / 2) - ((card_num / 2) * card_spacing)
	var y = get_viewport_rect().size.y + y_offset
	
	var tween : Tween = create_tween()
	tween.set_parallel()
	
	for i in get_child_count():
		var card : Card = get_child(i)
		
		var x : int = start_x + (i * card_spacing)
		var target_position : Vector2 = Vector2(x, y)
		tween.tween_property(card, "position", target_position, 1.0)
	
	tween.play()

func highlight_card() -> void:
	pass
