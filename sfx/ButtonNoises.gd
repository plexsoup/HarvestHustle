extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func hover():
	make_noise($HoverNoise)
	
func click():
	make_noise($ClickNoise)

func make_noise(noiseNode):
	var audioNode = noiseNode.duplicate()
	Global.stage_manager.add_child(audioNode)
	audioNode.play()
	# audioNode should terminate itself on finished
	

