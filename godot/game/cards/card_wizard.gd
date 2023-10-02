extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	deactivate()

func activate():
	animation_player.play("active")

func deactivate():
	animation_player.play("inactive") 
