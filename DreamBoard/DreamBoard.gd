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
	$ButtonNoises.click()
	Global.portrait_image = $VBoxContainer/Body/Character.imageNode.texture
	Global.objective_image = $VBoxContainer/Body/ObjectiveCard.imageNode.texture
	Global.aptitude_image = $VBoxContainer/Body/HBoxContainer/AptitudeCard.imageNode.texture
	Global.stage_manager.switch_scene("Level00")

	


func _on_RerollButton_pressed():
	$ButtonNoises.click()
	reroll_selectors()


func _on_Button_hover():
	$ButtonNoises.hover()
