extends Node2D

@onready var tower: Tower = get_node("%Tower")
@onready var card_hand = get_node("%CardHand")
@onready var capacity_gui = get_node("%CapacityUI")

var round_capacity_demand:int
var selected_card_type: Card.CardType = Card.CardType.CARD_TYPE_NORMAL
var block_click:bool = false

func _ready():
	self.round_capacity_demand = 0
	self.capacity_gui.demand = self.round_capacity_demand
	$CanvasLayer/Letter.show_letter("start")

func _process(delta):
	if Input.is_action_just_released("primary_action"):
		if not block_click:
			tower.place_preview_building()
		block_click = false
	if Input.is_action_just_released("close_letter"):
		self.tower.deselect_preview_building()
		self.card_hand.redraw()

func _on_card_hand_card_selected(card):
	self.block_click = true
	self.tower.select_preview_building(card._building)
	self.selected_card_type = card.card_type

func _on_tower_building_placed(position, capacity):
	post_round()
	await get_tree().process_frame
	pre_round()


func post_round():
	self.card_hand.drop_card()
#	self.card_hand.speek("Foo")
		# TODO check game over (over capacity)

func pre_round():
	var left_over = self.tower.add_sheep(self.round_capacity_demand)
	if left_over:
		print("not enough capacity, "+str(left_over)+" sheep couldn't move in")
	self.card_hand.draw_card(self.selected_card_type, 1)
	self.selected_card_type = Card.CardType.CARD_TYPE_NORMAL
	
	var capacities = []
	for i in range(5):
		var building := Building.new()
		building.generate_building()
		capacities.append(int(building.raw_capacity/3*0.9))
	self.round_capacity_demand = capacities[2]
	self.capacity_gui.demand = self.round_capacity_demand
	
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


func _on_click_detector_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_released():
		self.card_hand.click_anywhere()


func _on_card_hand_wizard_clicked():
	print("wizard")
	self.card_hand.click_anywhere()
