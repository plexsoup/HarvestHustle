"""
Add CommodityConverter.tscn instances as children to this node.


Takes an input and converts it to an output, on a Timer
- if no input, then generates output from bank account.
- if no ouptut, sends cash into player's bank account


Nodes can represent:
	- inputs where you acquire eggs, fertilizer, etc
	- production/processing where you add value to the materials
	- marketing where you buy an audience
	- audience produces customers

	- packaging 
	- shipping
	
	- customers
	
"""
tool

extends GraphNode




enum States { READY, MOVING, RESIZING, DISABLED }
var State = States.READY

var buffer_size = 10
var buffer = [] # push and pop product commodity names as required


export var resource_texture : Texture setget set_resource_texture
export var product : PackedScene

signal product_ready(prod)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_resizable(true)
	if resource_texture != null:
		$VBoxContainer/ResourcePic.texture = resource_texture
	State = States.DISABLED

func activate():
	State = States.READY
	
	

func set_resource_texture(newTexture : Texture):
	resource_texture = newTexture
	$TopDisplay/ResourcePic.texture = newTexture
	
func setup_slots():
	for slotNode in get_children():
		if slotNode.name != "TopDisplay":
			add_slot(slotNode, "left")

func add_slot(newNode, side:String):
	#add_child(newNode)
	var enable_left : bool = side == "left"
	var enable_right : bool = side == "right"
	var type_left = 0
	var type_right = 0
	var color_left = Color.green
	var color_right = Color.green
	var custom_left = null
	var custom_right = null
	var small_icon = make_small_icon(newNode.product_icon)
#	if enable_left and small_icon != null:
#		custom_left = small_icon # texture for input connector
#	elif enable_right and small_icon != null:
#		custom_right = small_icon # texture for output connector

	var slotID = newNode.get_position_in_parent()
	print("setting slot now at " + str(slotID))
	set_slot(
			slotID,
			enable_left, 
			type_left, 
			color_left, 
			enable_right, 
			type_right, 
			color_right, 
			custom_left, 
			custom_right
	)

	
func make_small_icon(bigIcon):
	var texture = ImageTexture.new()
	var image = Image.new()
	image = bigIcon.get_data()
	image.resize(16, 16, Image.INTERPOLATE_NEAREST)

	texture.create_from_image(image)

	return(texture)

	
	
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Engine.is_editor_hint():
		return
		
	if State == States.RESIZING:
		rect_size = get_local_mouse_position()
		if Input.is_action_pressed("resize_graphnode") == false:
			State = States.READY
	



# Warn users if the value hasn't been set.
func _get_configuration_warning():
	return ""
#	if get_child_count() < 2:
#		return "Add CommodityConverter nodes as children"
#	else:
#		return ""


func _on_HustleGraphNode_resize_request(_new_minsize):
	State = States.RESIZING
	
	


func _on_HustleGraphNode_dragged(_from, _to):
	State = States.READY



func _on_HustleGraphNode_offset_changed():
	State = States.MOVING



func _on_ProductionTimer_timeout():
	#spawn_product()
	pass

func get_commodity_count(commodityName):
	return buffer.count(commodityName)
	
func receive_commodity(commodityName):
	if buffer.size() < buffer_size:
		buffer.push_back(commodityName)

