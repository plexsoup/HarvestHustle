extends Control


var beat = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	init(Global.portrait_image_path, Global.objective_image_path)
	Global.audio_manager.subscribe_to_pulse_beat(self, "_on_beat_pulse")

func init(portraitImagePath : String, objectiveImagePath : String):
	# later on we can make a character class and an objective class. They can contain textures as properties
	if Global.portrait_image_path != null:
		$VBoxContainer/Body/Objective/PortraitTex.texture = load(portraitImagePath)
	if Global.objective_image_path != null:
		$VBoxContainer/Body/Objective/ObjectiveTex.texture = load(objectiveImagePath)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Panel_popup_hide():
	$VBoxContainer/Body/Board/Panel.queue_free()

func spawn_new_card():
	var hand = find_node("PlayerHand")
	hand.add_child(Global.card_database.draw_card())
	
func spawn_new_disaster():
	pass

func spawn_new_fortune():
	pass

func spawn_event():
	var diceroll = randf()
	if diceroll <= 1.00:
		spawn_new_card()
	elif diceroll < 0.00:
		spawn_new_disaster()
	else:
		spawn_new_fortune()
		
	

func _on_beat_pulse():
	$VBoxContainer/Body/LeftSide/VBoxContainer/BankAccount/Cash.text = str(Global.player.cash)
	beat += 1

	if beat % 12 == 0:
		if randf() > 0.33: # not EVERY time
			spawn_event()
