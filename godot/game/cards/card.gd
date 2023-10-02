class_name Card
extends Sprite2D

@onready var capacity_label : Label = %CapacityLabel
@onready var click_zone : Area2D =%ClickZone

@onready var preview_viewport = %PreviewViewport
@onready var preview_tile_map = %PreviewTileMap

enum CardType {CARD_TYPE_SCAFFOLD, CARD_TYPE_NORMAL}
var _card_type_color = {
	CardType.CARD_TYPE_NORMAL: Color.WHITE,
	CardType.CARD_TYPE_SCAFFOLD: Color.RED
}

var _building: TBuilding = null
var _preview_building: TBuilding = null
var _capacity: int = 0
var card_type: CardType = CardType.CARD_TYPE_NORMAL

const CARD_PREVIEW_SIZE : Vector2i = Vector2i(14, 14)

signal hover_begin(card : Card)
signal hover_end(card : Card)
signal selected(card : Card)

func _ready():
	self.click_zone.mouse_entered.connect(self._on_ClickZone_mouse_entered)
	self.click_zone.mouse_exited.connect(self._on_ClickZone_mouse_exited)
	self.click_zone.input_event.connect(self._on_ClickZone_input_event)
	capacity_label.text = str(_capacity)

func init(card_type : CardType):
	self.self_modulate = _card_type_color[card_type]
	self.card_type = card_type
	
	var building := Building.new()
	
	if card_type == Card.CardType.CARD_TYPE_SCAFFOLD:
		building.generate_scaffold()
	else:
		assert(card_type == Card.CardType.CARD_TYPE_NORMAL)
		
		building.generate_building()
	var t_building := TBuilding.from_building(building)
	
	self.init_building(t_building)
	self.init_capacity(t_building.capacity)
	capacity_label.text = str(_capacity)

func init_building(building: TBuilding):
	_building = building
	_preview_building = TBuilding.new(CARD_PREVIEW_SIZE, self.preview_tile_map)
	_preview_building.stamp(Vector2i(CARD_PREVIEW_SIZE.x/2-building.size.x/2, CARD_PREVIEW_SIZE.y/2-building.size.y/2), building)

func init_capacity(capacity : int):
	_capacity = capacity


func _on_ClickZone_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		self.selected.emit(self)
		

func _on_ClickZone_mouse_entered():
	is_hovered = true
	self.hover_begin.emit(self)

func _on_ClickZone_mouse_exited():
	is_hovered = false
	self.hover_end.emit(self)

var focus_tween : Tween

var is_hovered := false
var is_focused := false
var is_selected := false

func focus():
	is_focused = true
	if focus_tween:
		focus_tween.stop()
		focus_tween.kill()
	
	if not is_selected:
		z_index = 99
	
	focus_tween = create_tween()
	focus_tween.set_trans(Tween.TRANS_EXPO)
	focus_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	focus_tween.play()

func blur():
	is_focused = false
	if focus_tween:
		focus_tween.stop()
		focus_tween.kill()
	
	if not is_selected:
		z_index = 0
	else:
		z_index = 50
	
	focus_tween = create_tween()
	focus_tween.tween_property(self, "scale", Vector2.ONE, 0.4)
	focus_tween.play()

func select():
	is_selected = true
	z_index = 50

func deselect():
	is_selected = false
	
	if not is_focused:
		z_index = 0
	pass
