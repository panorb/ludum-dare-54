extends Sprite2D

#@onready var animation_player: AnimationPlayer = $PlaceAnim

func _ready():
	pass

func activate():
	get_child(0).play("default")
