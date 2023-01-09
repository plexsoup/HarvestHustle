extends "res://Production/Commodities/ProductIO.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#func custom_setup():
#	Global.audio_manager.subscribe_to_pulse_beat(self, "_on_pulse_received")
#
#
#func _on_pulse_received():
#	if get_parent().has_method("requirements_met"):
#		if get_parent().requirements_met():
#			Global.player.cash += 1
#

func _on_commodity_received(): # comes from the GraphNode, connected when it added this node as an output with no ports enabled.
	Global.player.cash += 1
	print("ATM got cash deposit")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
