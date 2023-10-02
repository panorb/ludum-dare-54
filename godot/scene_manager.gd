extends Node

var packed_scenes := {
	"main_menu": preload("res://gui/main_menu.tscn"),
	"game": preload("res://game/game.tscn"),
	"credits": preload("res://gui/credits.tscn"),
};
var start_scene := "main_menu";

var _scenes := {};
@onready var _curr_scene: Node = get_node_or_null("/root/World");
@onready var _root = get_node("/root");

func _ready() -> void:
	if _curr_scene != null:
		show_scene(start_scene)

func show_scene(scene_name: String) -> void:
	if !_scenes.has(scene_name) or scene_name == "game":
		var packed_scene: PackedScene = packed_scenes[scene_name]
		_scenes[scene_name] = packed_scene.instantiate()

	var scene: Node = _scenes[scene_name]
	if scene == _curr_scene:
		return
	if _curr_scene != null:
		_root.remove_child.call_deferred(_curr_scene)
	_curr_scene = scene
	_root.add_child.call_deferred(scene)
