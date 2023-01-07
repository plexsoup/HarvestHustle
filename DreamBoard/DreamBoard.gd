extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NextButton_pressed():
	$AnimationPlayer.play("RevealDream")




func _on_StartGameButton_pressed():
	Global.portrait_image_path = $VBoxContainer/Body/Character.imagePath
	Global.objective_image_path = $VBoxContainer/Body/ObjectiveCard.imagePath
	Global.stage_manager.switch_scene("Game")

	
