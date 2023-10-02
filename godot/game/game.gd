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


var round_capacity_demand:int

func _ready():
	self.round_capacity_demand = 0
	$CanvasLayer/Letter.show_letter("start")
	interaction_manager.player_height_changed.connect(self._on_player_height_changed)

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

func _on_player_height_changed(player_height: float):
	# Errechnen der Prozente
	var percent_city_noise = inverse_lerp(CITY_NOISE_MAX_HEIGHT, 0.0, player_height)
	var percent_troposphere = 0.0
	var percent_space = 0.0
	
	if 0.0 > percent_city_noise and percent_city_noise < 1.0:
		percent_city_noise =  player_height / CITY_NOISE_MAX_HEIGHT
		percent_troposphere = 1.0 - percent_city_noise

	if percent_city_noise <= 0.01:
		city_noise_sound.stop()
	else:
		city_noise_sound.volume_db(linear_to_db(percent_city_noise))
		if !city_noise_sound.playing:
			city_noise_sound.play()

	if percent_troposphere <= 1.0:
		troposphere_sound.stop()
	else:
		troposphere_sound.volume_db(linear_to_db(percent_troposphere))
		if troposphere_sound.playing:
			troposphere_sound.play()

	if percent_space <= 1.0:
		space_sound.stop()

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
