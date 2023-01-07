tool
extends VBoxContainer

export var resource_image : Texture setget set_image
export var resource_name : String setget set_name
export var hustle_graph_node : PackedScene
export (String, MULTILINE) var description : String



enum Categories { SUPPLIER, PRODUCTION, CUSTOMER, ACCELERATOR, LIMITER, SHIPPING, PACKAGING }
export (Categories) var resource_category = Categories.SUPPLIER setget set_category


enum States { READY, DRAGGING, DROPPED }
var State = States.READY

signal resource_dropped(resource, location)

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return
	
	if hustle_graph_node == null:
		hustle_graph_node = load("res://GraphNetwork/HustleGraphNode.tscn")
	
	if resource_image != null:
		$ResourceImage.texture = resource_image
		$ResourceImage.show()

		$Sprite.texture = resource_image
		$Sprite.hide()
	if resource_name != null:
		$ResourceNameLabel.text = resource_name
	
	if resource_category != null:
		$ResourceCategoryLabel.text = Categories.keys()[resource_category].capitalize()


	delayed_ready(0.25) # let parents initialize first


func delayed_ready(timeToWait):
	var timer = get_tree().create_timer(timeToWait)
	yield(timer, "timeout")
	var err = connect("resource_dropped", Global.hustle_graph, "_on_resource_dropped")
	if err != OK:
		printerr(self.name + " ResourceCard.gd")
		printerr(err)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		return

	if State == States.DRAGGING:
		$Sprite.set_global_position(get_global_mouse_position())

		if Input.is_action_just_pressed("click") and $ClickTimer.is_stopped():
			drop_resource()

func set_name(myName):
	resource_name = myName
	$ResourceNameLabel.text = myName

func set_image(myImage):
	resource_image = myImage
	$ResourceImage.texture = myImage

func set_category(myCategory):
	$ResourceCategoryLabel.text = Categories.keys()[myCategory].capitalize()
	resource_category = myCategory
	
func drop_resource():
	State = States.DROPPED
	emit_signal("resource_dropped", hustle_graph_node, get_global_mouse_position())
	


func _on_ResourceCard_gui_input(event):
	if State != States.READY:
		return
		
	# drag the card onto the stage
	if event is InputEventMouseButton and event.is_pressed() == true:
		$ResourceImage.hide()
		$ResourceNameLabel.hide()
		$Sprite.show()
		State = States.DRAGGING
		$ClickTimer.start()
		
		print(event)


func _on_ClickTimer_timeout():
	pass # Replace with function body.
