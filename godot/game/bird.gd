extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.spawn_time = Time.get_ticks_msec()

var speed_offset = Vector2(20,0)
var spawn_time
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position += speed_offset * delta
	
	if(Time.get_ticks_msec() > self.spawn_time + 30000):
		self.queue_free()

