extends Node2D


# Called when the node enters the scene tree for the first time.
var scene = load("res://game/bird.tscn") as PackedScene
func _ready():
	next_spawn = 0;

var random = RandomNumberGenerator.new()
var next_spawn
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var curr_time = Time.get_ticks_msec()
	if next_spawn > curr_time:
		return
	var node = scene.instantiate() as Bird
	if random.randf() > 0.5:
		node.direction = -1.0
		node.scale.x = -1.0
	node.position.x = -220 * node.direction
	node.position.y = random.randf_range(-300, -1000)
	self.add_child(node)
	print("spawned bird")
	next_spawn = Time.get_ticks_msec() + 2000
