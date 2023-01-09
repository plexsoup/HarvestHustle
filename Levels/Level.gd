extends Control


var beat = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	init(Global.portrait_image, Global.objective_image)
	Global.audio_manager.subscribe_to_pulse_beat(self, "_on_beat_pulse")

func init(portraitImage : Texture, objectiveImage : Texture):
	# later on we can make a character class and an objective class. They can contain textures as properties
	$VBoxContainer/Body/Objective/PortraitTex.texture = portraitImage
	$VBoxContainer/Body/Objective/ObjectiveTex.texture = objectiveImage
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Panel_popup_hide():
	$VBoxContainer/Body/Board/Panel.queue_free()

func spawn_new_card():
	var hand = find_node("PlayerHand")
	if hand.get_child_count() < 6:
		var newCard = Global.card_database.draw_card()
		if newCard != null:
			hand.add_child(newCard)
	
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
