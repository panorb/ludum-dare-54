extends Control

const VALUE_CHANGE_SECONDS := 0.02

@onready var population_label = %PopulationLabel
@onready var capacity_label = %CapacityLabel
@onready var demand_label = %DemandLabel

var population_tween : Tween
var capacity_tween : Tween
var demand_tween : Tween
var _displayed_population: int = 0
var _displayed_capacity: int = 0
var _displayed_demand: int = 0

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
var demand: int = 0:
	set(value):
		demand = value
		if demand_tween:
			demand_tween.stop()
			demand_tween.kill()
		demand_tween = create_tween()
		demand_tween.tween_property(self, "_displayed_demand", value, abs(_displayed_demand - value) * VALUE_CHANGE_SECONDS)
		demand_tween.play()

func _process(delta):
	population_label.text = str(_displayed_population)
	capacity_label.text = str(_displayed_capacity)
	demand_label.text = str(_displayed_demand)


func _on_tower_capacity_update(capacity_used, capacity_total):
	self.population = capacity_used
	self.capacity = capacity_total
