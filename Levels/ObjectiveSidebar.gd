extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.audio_manager.subscribe_to_pulse_beat(self, "_on_pulse_beat")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_pulse_beat():
	$MarginContainer/ProgressBar.value = Global.player.cash
	$HBoxContainer/Cash.text = "$" + str(Global.player.cash).pad_decimals(2)
	
	
	
