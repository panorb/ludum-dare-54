extends Control

const VALUE_CHANGE_SECONDS := 0.02

@onready var population_label = %PopulationLabel
@onready var capacity_label = %CapacityLabel

var population_tween : Tween = create_tween()
var capacity_tween : Tween = create_tween()
var _displayed_population: int = 0
var _displayed_capacity: int = 0

var population: int = 0:
	set(value):
		population = value
		if population_tween:
			population_tween.stop()
			population_tween.kill()
		population_tween = create_tween()
		population_tween.tween_property(self, "_displayed_population", value, abs(_displayed_population - value) * VALUE_CHANGE_SECONDS)
		population_tween.play()
var capacity: int = 0:
	set(value):
		capacity = value
		if capacity_tween:
			capacity_tween.stop()
			capacity_tween.kill()
		capacity_tween = create_tween()
		capacity_tween.tween_property(self, "_displayed_capacity", value, abs(_displayed_capacity - value) * VALUE_CHANGE_SECONDS)
		capacity_tween.play()

func _process(delta):
	population_label.text = str(_displayed_population)
	capacity_label.text = str(_displayed_capacity)
