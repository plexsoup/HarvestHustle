extends VBoxContainer


export var images_location = "res://Portraits/"

var images = []
var currentImage = 0
var imagePath : String
var imageNode : TextureRect

export var title = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	get_images()
	$NameLabel.text = title
	imageNode = find_node("Image")
	reroll()

func reroll():
	advance_image(randi()%images.size())



func get_images():
	images = dir_contents(images_location)

	
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
	currentImage += direction
	
	currentImage = currentImage % images.size()
#	if currentImage < 0:
#		currentImage = images.size() -1
#	elif currentImage == images.size():
#		currentImage = 0
	imageNode.texture = load(images[currentImage])
	imagePath = images[currentImage]


func _on_LeftButton_pressed():
	advance_image(1)

func _on_RightButton_pressed():
	advance_image(-1)
