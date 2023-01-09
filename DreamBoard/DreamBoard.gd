extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func reroll_selectors():
	$VBoxContainer/Body/Character.reroll()
	$VBoxContainer/Body/HBoxContainer/AptitudeCard.reroll()
	$VBoxContainer/Body/ObjectiveCard.reroll()
	






func _on_StartGameButton_pressed():
	Global.portrait_image_path = $VBoxContainer/Body/Character.imagePath
	Global.objective_image_path = $VBoxContainer/Body/ObjectiveCard.imagePath
	Global.aptitude_image_path = $VBoxContainer/Body/HBoxContainer/AptitudeCard.imagePath
	Global.stage_manager.switch_scene("Level00")

	


func _on_RerollButton_pressed():
	reroll_selectors()
