class_name Tower
extends Node2D

@export var tileMap: TileMap = null
@onready var building_manager:BuildingManager = get_node("%BuildingManager")

var capacity_total: int
var capacity_used: int

signal building_placed(position:Vector2i, capacity:int)
signal capacity_update(capacity_used: int, capacity_total: int)

var height:
	get:
		return building_manager.height

# Called when the node enters the scene tree for the first time.
func _ready():
	self.capacity_total = 12
	self.capacity_used = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_interaction_manager_primary_interaction_just_pressed_sig():
	var local_coordinates = get_local_mouse_position()
	if tileMap != null:
		var tilemap_coords = tileMap.local_to_map(local_coordinates)
		print("Tilemap coords clicked @ " + str(tilemap_coords))

func select_preview_building(building:TBuilding):
	self.building_manager.select_preview_building(building)

func deselect_preview_building():
	self.building_manager.deselect_preview_building()

func place_preview_building():
	self.building_manager.place_preview_building()


func _on_side_building_right_tower_spam(position):
	self.building_manager.tower_spam_block(position)

func _on_side_building_left_tower_spam(position):
	self.building_manager.tower_spam_block(position)


func _on_building_manager_building_placed(position: Vector2i, capacity: int):
	building_placed.emit(position, capacity)
	capacity_total += capacity
	capacity_update.emit(capacity_used, capacity_total)

func add_sheep(amount:int) -> int:
	var amount_actual = min(amount, self.capacity_total - self.capacity_used)
	self.capacity_used += amount_actual
	capacity_update.emit(capacity_used, capacity_total)
	return amount - amount_actual

func possible_to_place(building:TBuilding) -> bool:
	var positions = self.building_manager.get_possible_placement(building)
	return bool(0 < len(positions))
