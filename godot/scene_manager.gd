extends Node

var packed_scenes := {
	"game": preload("res://game/game.tscn")
};
var start_scene := "game";

var _scenes := {};
var _curr_scene: Node = null;
@onready var _world = get_node("/root/World");

func _ready() -> void:
	_init_scenes()
	show_scene(start_scene)

func show_scene(scene_name: String) -> void:
	var scene: Node = _scenes[scene_name]
	if scene == _curr_scene:
		return
	if _curr_scene != null:
		_world.remove_child(_curr_scene)
	_curr_scene = scene
	_world.add_child(scene)

func _init_scenes() -> void:
	for scene_name in packed_scenes:
		var packed_scene: PackedScene = packed_scenes[scene_name]
		_scenes[scene_name] = packed_scene.instantiate()
