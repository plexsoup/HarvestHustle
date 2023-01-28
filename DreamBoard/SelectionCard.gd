extends VBoxContainer


export var images_location = "res://Portraits/"

var image_texture_rects = []
var currentImageIdx = 0
var imagePath : String
var imageNode : TextureRect

export var title = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	get_images()
	$NameLabel.text = title
	imageNode = $HBoxContainer/Image
	reroll()

func reroll():
	advance_image(randi()%image_texture_rects.size())



func get_images():
	image_texture_rects = $ImageTabs.get_children()
	
	#images = dir_contents(images_location)
	

	
func dir_contents(path):
	var files = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				if file_name.get_extension() == "png":
					files.push_back(path.plus_file(file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return files

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func advance_image(direction : int):
	currentImageIdx += direction
	
	currentImageIdx = currentImageIdx % image_texture_rects.size()
#	if currentImage < 0:
#		currentImage = images.size() -1
#	elif currentImage == images.size():
#		currentImage = 0
	imageNode.texture = image_texture_rects[currentImageIdx].texture

func make_noise(noiseNode):
	# noises should come from tempNoise.tscn
	$ButtonNoises.hover()

func _on_LeftButton_pressed():
	advance_image(1)
	$ButtonNoises.click()

func _on_RightButton_pressed():
	advance_image(-1)
	$ButtonNoises.click()


func _on_Button_hover():
	make_noise($Audio/HoverNoise)
