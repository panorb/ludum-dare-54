extends Node

var packed_scenes := {
	"game": preload("res://game/game.tscn")
};
var start_scene := "game";

var _scenes := {};
@onready var _curr_scene: Node = get_node_or_null("/root/World");
@onready var _root = get_node("/root");

func _ready() -> void:
	_init_scenes()
	if _curr_scene != null:
		show_scene(start_scene)

func show_scene(scene_name: String) -> void:
	var scene: Node = _scenes[scene_name]
	if scene == _curr_scene:
		return
	if _curr_scene != null:
		_root.remove_child.call_deferred(_curr_scene)
	_curr_scene = scene
	_root.add_child.call_deferred(scene)

func _init_scenes() -> void:
	for scene_name in packed_scenes:
		var packed_scene: PackedScene = packed_scenes[scene_name]
		_scenes[scene_name] = packed_scene.instantiate()
