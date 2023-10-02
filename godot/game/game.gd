extends Node2D

@onready var tower: Tower = get_node("%Tower")
@onready var card_hand = get_node("%CardHand")
@onready var capacity_gui = get_node("%CapacityUI")

@onready var letter = %Letter

var round_capacity_demand: int
var selected_card_type: Card.CardType = Card.CardType.CARD_TYPE_NORMAL

enum GameState { PRE_GAME, INITIAL, WARNED_ONCE, WARNED_TWICE, GAME_OVER }
var current_state : GameState

func _ready():
	self.round_capacity_demand = 0
	self.capacity_gui.demand = self.round_capacity_demand
	
	self.letter.close.connect(_on_Letter_close)
	
	change_game_state(GameState.PRE_GAME)

func change_game_state(state : GameState):
	if state == GameState.PRE_GAME:
		letter.show_letter("start")
	elif state == GameState.WARNED_ONCE:
		letter.show_letter("first_warning")
	elif state == GameState.WARNED_TWICE:
		letter.show_letter("second_warning")
	elif state == GameState.GAME_OVER:
		letter.show_letter("game_over", [int(tower.height / 3), tower.capacity_used])
	
	current_state += 1

func _on_Letter_close():
	if current_state == GameState.GAME_OVER:
		# game overed
		SceneManager.show_scene("main_menu")
		return
	


func _process(delta):
	if Input.is_action_just_released("primary_action"):
		tower.place_preview_building()
	if Input.is_action_just_released("close_letter"):
		self.tower.deselect_preview_building()
		self.card_hand.redraw()

func _on_card_hand_card_selected(card):
	self.tower.select_preview_building(card._building)
	self.selected_card_type = card.card_type

func _on_tower_building_placed(position, capacity):
	post_round()
	await get_tree().process_frame
	pre_round()


func post_round():
	self.card_hand.drop_card()

func pre_round():
	var left_over = self.tower.add_sheep(self.round_capacity_demand)
	if left_over:
		print("not enough capacity, "+str(left_over)+" sheep couldn't move in")
		if current_state == GameState.INITIAL:
			change_game_state(GameState.WARNED_ONCE)
		elif current_state == GameState.WARNED_ONCE:
			change_game_state(GameState.WARNED_TWICE)
		elif current_state == GameState.WARNED_TWICE:
			change_game_state(GameState.GAME_OVER)
	
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
