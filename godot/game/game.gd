extends Node2D

@onready var tower: Tower = get_node("%Tower")
@onready var card_hand = get_node("%CardHand")
@onready var interaction_manager = %InteractionManager
@onready var city_noise_sound := %CityNoiseSound
@onready var troposphere_sound := %TroposphereSound
@onready var space_sound := %SpaceSound

const CITY_NOISE_MAX_HEIGHT = 200.0
const TROPOSPHERE_MAX_HEIGHT = 400.0
const SPACE_MAX_HEIGHT = 600.0

@onready var capacity_gui = get_node("%CapacityUI")

@onready var letter = %Letter

var round_capacity_demand: int
var selected_card_type: Card.CardType = Card.CardType.CARD_TYPE_NORMAL
var block_click:bool = false

enum GameState { PRE_GAME, INITIAL, WARNED_ONCE, WARNED_TWICE, WARNED_THRICE, GAME_OVER, GAME_WON, GAME_WON_END }
var current_state : GameState

func _ready():
	self.round_capacity_demand = 0

	$CanvasLayer/Letter.show_letter("start")
	interaction_manager.player_height_changed.connect(self._on_player_height_changed)

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
	elif state == GameState.WARNED_THRICE:
		letter.show_letter("third_warning")
	elif state == GameState.GAME_OVER:
		$GameLostSound.play()
		letter.show_letter("game_over", [int(tower.height / 3), tower.capacity_used])
	elif state == GameState.GAME_WON:
		letter.show_letter("win")
		$GameWonSound.play()
	
	current_state += 1

func _on_Letter_close():
	if current_state == GameState.GAME_OVER:
		# game overed
		SceneManager.show_scene("main_menu")
		return

func _process(delta):
	if Input.is_action_just_released("primary_action"):
		if not block_click:
			tower.place_preview_building()
		block_click = false

func _on_card_hand_card_selected(card):
	self.block_click = true
	self.tower.select_preview_building(card._building)
	self.selected_card_type = card.card_type

func _on_tower_building_placed(position, capacity):
	post_round()
	await get_tree().process_frame
	pre_round()

func _on_player_height_changed(player_height: float):
	# Errechnen der Prozente
	return
	var percent_city_noise = inverse_lerp(CITY_NOISE_MAX_HEIGHT, 0.0, player_height)
	var percent_troposphere = 0.0
	var percent_space = 0.0
	
	if 0.0 > percent_city_noise and percent_city_noise < 1.0:
		percent_city_noise =  player_height / CITY_NOISE_MAX_HEIGHT
		percent_troposphere = 1.0 - percent_city_noise

	if percent_city_noise <= 0.01:
		city_noise_sound.stop()
	else:
		city_noise_sound.volume_db = linear_to_db(percent_city_noise)
		if !city_noise_sound.playing:
			city_noise_sound.play()

	if percent_troposphere <= 1.0:
		troposphere_sound.stop()
	else:
		troposphere_sound.volume_db = linear_to_db(percent_troposphere)
		if troposphere_sound.playing:
			troposphere_sound.play()

	if percent_space <= 1.0:
		space_sound.stop()

func game_won():
	$GameWonSound.play()

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
	
	if current_state >= GameState.GAME_WON and self.tower.capacity_total >= 400:
		change_game_state(GameState.GAME_WON)
	
	self.card_hand.draw_card(self.selected_card_type, 1)
	self.selected_card_type = Card.CardType.CARD_TYPE_NORMAL
	
	var capacities = []
	for i in range(5):
		var building := Building.new()
		building.generate_building()
		capacities.append(int(building.raw_capacity/3*0.9))
	capacities.sort()
	self.round_capacity_demand = capacities[2]
	if self.tower.capacity_total >= 400:
		var distance_to_goal = 400 - self.tower.capacity_used
		
		if distance_to_goal > 0:
			self.round_capacity_demand = distance_to_goal
		else:
			self.round_capacity_demand = 0
		
	self.capacity_gui.demand = self.round_capacity_demand
	
	var found = false
	for card in self.card_hand.hand_cards:
		if card.card_type == Card.CardType.CARD_TYPE_SCAFFOLD:
			continue
		
		var possible_to_place = self.tower.possible_to_place(card._building)
		print(possible_to_place)
		if possible_to_place:
			found = true
			break
	if not found and current_state in [GameState.GAME_WON, GameState.GAME_WON_END]:
		letter.show_letter("good_ending")
		# print("no cards can be placed any more")
		# TODO check game over (building placement)

func _on_card_hand_card_deselected():
	self.tower.deselect_preview_building()


func _on_click_detector_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_released() and event.button_index not in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		self.card_hand.click_anywhere()


func _on_card_hand_wizard_clicked():
	self.card_hand.click_anywhere()


func _on_tower_placement_failed(error_code):
	if error_code == 1:
		print("outside")
		self.card_hand.say_error("overlap")
	elif error_code == 2:
		print("overlap")
		self.card_hand.say_error("overlap")
	elif error_code == 3:
		print("right")
		self.card_hand.say_error("right_support_misssing")
	elif error_code == 4:
		print("left")
		self.card_hand.say_error("left_support_missing")
