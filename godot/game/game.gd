extends Node2D

@onready var tower: Tower = get_node("%Tower")
@onready var card_hand = get_node("%CardHand")

func _process(delta):
	if Input.is_action_just_released("primary_action"):
		tower.place_preview_building()
	if Input.is_action_just_released("close_letter"):
		self.tower.deselect_preview_building()
		self.card_hand.redraw()

func _on_card_hand_card_selected(card):
	self.tower.select_preview_building(card._building)

func _on_tower_building_placed(position):
	self.card_hand.drop_card()
	self.card_hand.draw_card(1)

func _on_card_hand_card_deselected():
	self.tower.deselect_preview_building()
