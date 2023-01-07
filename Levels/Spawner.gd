extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.spawner = self

func _on_spawn_requested(spawned_object):
	add_child(spawned_object)
