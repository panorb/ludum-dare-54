extends Node2D

@onready var tower: Tower = get_node("%Tower")
@onready var card_hand = get_node("%CardHand")

var round_capacity_demand:int

func _ready():
	self.round_capacity_demand = 0

func _process(delta):
	if Input.is_action_just_released("primary_action"):
		tower.place_preview_building()
	if Input.is_action_just_released("close_letter"):
		self.tower.deselect_preview_building()
		self.card_hand.redraw()

func _on_card_hand_card_selected(card):
	self.tower.select_preview_building(card._building)

func _on_tower_building_placed(position, capacity):
	post_round()
	pre_round()
	

func post_round():
	self.card_hand.drop_card()
	var left_over = self.tower.add_sheep(self.round_capacity_demand)
	if left_over:
		print("not enough capacity, "+str(left_over)+" sheep couldn't move in")
		# TODO check game over (over capacity)

func pre_round():
	self.card_hand.draw_card(Card.CardType.CARD_TYPE_NORMAL, 1)
	self.round_capacity_demand = 5
	var found = false
	for card in self.card_hand.hand_cards:
		var possible_to_place = self.tower.possible_to_place(card._building)
		print(possible_to_place)
		if possible_to_place:
			found = true
			break
	if not found:
		print("no cards can be placed any more")
		# TODO check game over (building placement)

func _on_card_hand_card_deselected():
	self.tower.deselect_preview_building()
