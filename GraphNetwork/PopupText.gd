extends Node2D





func _ready():
	pass

func popup():
	pop_direction(1)

func popdown():
	pop_direction(-1)
	
func pop_direction(direction : int):
	var tween = $Tween
	var currentPos = position
	tween.interpolate_property(
		self, "scale", Vector2(0, 0), Vector2(2, 2), 1.5, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(
		self, "position", currentPos, currentPos + Vector2(0, -direction * 50), 1.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	
	queue_free()


func set_text(text):
	$Label.text = text
