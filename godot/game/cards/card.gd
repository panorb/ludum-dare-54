class_name Card
extends Sprite2D

@onready var capacity_label : Label = get_node("%CapacityLabel")

func _ready():
	init(5)

func init(capacity : int):
	capacity_label.text = str(capacity)


