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

extends GraphNode


var nextSlotPosition = 1

enum States { READY, MOVING, RESIZING, DISABLED }
var State = States.READY

var buffer_size = 10
var buffer = [] # push and pop product commodity names as required


export var resource_texture : Texture
export var product : PackedScene

signal product_ready(prod)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_resizable(true)
	if resource_texture != null:
		$VBoxContainer/ResourcePic.texture = resource_texture
	State = States.READY

	
	

func add_slot(side:String):

	var enable_left : bool
	var enable_right : bool
	if side == "left":
		enable_left = true
		enable_right = false
	else:
		enable_right = true
		enable_left = false
	var type_left = 0
	var type_right = 0
	var color_left = Color.green
	var color_right = Color.green
	var custom_left = null # texture for input connector
	var custom_right = null # texture for output connector
	
	set_slot(
			nextSlotPosition, 
			enable_left, 
			type_left, 
			color_left, 
			enable_right, 
			type_right, 
			color_right, 
			custom_left, 
			custom_right
	)

	nextSlotPosition += 1

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		return
		
	if State == States.RESIZING:
		rect_size = get_local_mouse_position()
		if Input.is_action_pressed("resize_graphnode") == false:
			State = States.READY
	$VBoxContainer/StateLabel.text = States.keys()[State]


# Warn users if the value hasn't been set.
func _get_configuration_warning():
	if get_child_count() < 2:
		return "Add CommodityConverter nodes as children"
	else:
		return ""


func _on_HustleGraphNode_resize_request(new_minsize):
	State = States.RESIZING
	
	


func _on_HustleGraphNode_dragged(from, to):
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

