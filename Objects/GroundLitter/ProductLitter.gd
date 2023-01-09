extends Area2D

var product_name : String
enum States { READY, DEAD }
var State = States.READY

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func play_random_sound():
	var sounds = $Audio.get_children()
	var randomIdx = randi()%sounds.size()
	var randSound = sounds[randomIdx]
	randSound.set_pitch_scale(rand_range(0.8, 1.2))
	randSound.play()

func _on_ProductLitter_area_entered(area):
	if State == States.READY:
		State = States.DEAD
		if area.name == "Cursor":
			if product_name == "Cash":
				Global.player.cash += 1
			play_random_sound()
			spawn_popup_number(1)
			$DeathTimer.start()
		

func spawn_popup_number(value):
	var popupText = load("res://GraphNetwork/PopupText.tscn").instance()
	popupText.set_text(str(value))
	Global.hustle_graph.add_child(popupText)
	popupText.position = Global.hustle_graph.get_local_mouse_position()

	if value < 0:
		popupText.set_modulate(Color.brown)
		popupText.popdown()
	else:
		popupText.set_modulate(Color.green)
		popupText.popup()


func die():
	State = States.DEAD
	
	var tween = get_tree().create_tween()
	#tween.tween_property(self, "modulate", Color(0,0,0,0), 1)
	tween.tween_property(self, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_ELASTIC)

	tween.tween_callback(self, "queue_free")

	
func _on_DurationTimer_timeout():
	die()


func _on_DeathTimer_timeout():
	queue_free()
