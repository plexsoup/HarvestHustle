extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	init(Global.portrait_image_path, Global.objective_image_path)


func init(portraitImagePath : String, objectiveImagePath : String):
	# later on we can make a character class and an objective class. They can contain textures as properties
	$VBoxContainer/Body/Objective/PortraitTex.texture = load(portraitImagePath)
	$VBoxContainer/Body/Objective/ObjectiveTex.texture = load(objectiveImagePath)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
