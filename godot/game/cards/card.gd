class_name Card
extends Sprite2D

@onready var capacity_label : Label = get_node("%CapacityLabel")
@onready var click_zone : Area2D = get_node("ClickZone")

signal hover_begin(card : Card)
signal hover_end(card : Card)
signal selected(card : Card)

func _ready():
	self.click_zone.mouse_entered.connect(self._on_ClickZone_mouse_entered)
	self.click_zone.mouse_exited.connect(self._on_ClickZone_mouse_exited)
	self.click_zone.input_event.connect(self._on_ClickZone_input_event)
	init(5)

func init(capacity : int):
	capacity_label.text = str(capacity)

func _on_ClickZone_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.is_pressed():
		self.selected.emit(self)

func _on_ClickZone_mouse_entered():
	self.hover_begin.emit(self)

func _on_ClickZone_mouse_exited():
	self.hover_end.emit(self)

var focus_tween : Tween

func focus():
	if focus_tween:
		focus_tween.stop()
		focus_tween.kill()
	z_index = 99
	focus_tween = create_tween()
	focus_tween.set_trans(Tween.TRANS_EXPO)
	focus_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	focus_tween.play()

func blur():
	if focus_tween:
		focus_tween.stop()
		focus_tween.kill()
	z_index = 0
	focus_tween = create_tween()
	focus_tween.tween_property(self, "scale", Vector2.ONE, 0.4)
	focus_tween.play()
