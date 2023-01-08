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
#tool

extends GraphNode




enum States { READY, MOVING, RESIZING, DISABLED }
var State = States.READY

var buffer_size = 10
var buffer = [] # push and pop product commodity names as required


export var resource_texture : Texture setget set_resource_texture
var product : MarginContainer
var product_name : String

var requirements = [] # list of Commodity names required to produce product
var outputs = [] # list of Commodity names produced by this node

var production_delay setget set_production_delay
var rest_delay setget set_rest_delay
var burst_size : int
var produced_this_burst : int = 0

var tone : AudioStream setget set_tone


var short_desc setget set_short_desc
var long_desc setget set_long_desc

var prev_rect_size # for hiding the portrait picture

signal product_ready(prod)

# Called when the node enters the scene tree for the first time.
func _ready():
	

	set_resizable(true)
	if resource_texture != null:
		$VBoxContainer/ResourcePic.texture = resource_texture
		$TopDisplay/InfoVBox/PopupInfoDialog/PopupHbox/ResourcePic2.texture = resource_texture
	State = States.DISABLED

# The graph doesn't care about our product signals
#	var err=connect("product_ready", Global.hustle_graph, "spawn_product")
#	if err != OK:
#		print("Error connecting to hustle_graph: ", err)


func activate():
	State = States.READY


func set_short_desc(newShortDesc):
	short_desc = newShortDesc
	$TopDisplay/InfoVBox/HBoxContainer/ShortDescLabel.text = newShortDesc


func set_long_desc(newLongDesc : String):
	if newLongDesc != null:
		long_desc = newLongDesc
		find_node("LongDescLabel").text = newLongDesc

func set_production_delay(newDelay):
	$TopDisplay/InfoVBox/ProductionTimer.set_wait_time(newDelay)

func set_rest_delay(newDelay):
	$TopDisplay/InfoVBox/RestTimer.set_wait_time(newDelay)

func set_tone(newTone):
	$TopDisplay/InfoVBox/AudioStreamPlayer2D.stream = newTone
	tone = newTone


func set_resource_texture(newTexture : Texture):
	resource_texture = newTexture
	$TopDisplay/InfoVBox/ResourcePic.texture = newTexture
	$TopDisplay/InfoVBox/PopupInfoDialog/PopupHbox/ResourcePic2.texture = newTexture
	
#func setup_slots():
#	for slotNode in get_children():
#		if slotNode.name != "TopDisplay":
#			add_slot(slotNode, "left")


func add_outputs(newOutputs : Array):
	add_slots(newOutputs, "output")

func add_inputs(newInputs : Array):
	add_slots(newInputs, "input")
	add_dummy_spacer()
	
func add_dummy_spacer():
	var spacer = MarginContainer.new()
	spacer.rect_min_size = Vector2(5, 10)
	spacer.rect_size = spacer.rect_min_size
	add_child(spacer)
#	var colorRec = ColorRect.new()
#	colorRec.color = Color.burlywood
#	colorRec.rect_min_size = Vector2(30, 50)
#	spacer.add_child(colorRec)


func add_slots(newSlots : Array, portType : String):
	for i in range(newSlots.size()):
		var newSlotNode = newSlots[i].duplicate()
		add_slot(newSlotNode, portType)


func add_slot(newNode, side:String):
	# the newNode to add should inherit from Product.tscn
	if side == "input":
		requirements.append(newNode.name)
	else:
		outputs.append(newNode.name)

	add_child(newNode) # Important
	
	
	
	var enable_left : bool = side == "input"
	var enable_right : bool = side == "output"
	var type_left = 0
	var type_right = 0
	var color_left = Color.green
	var color_right = Color.green
	var custom_left = null
	var custom_right = null
#	var small_icon = make_small_icon(newNode.product_icon)
#	if enable_left and small_icon != null:
#		custom_left = small_icon # texture for input connector
#	elif enable_right and small_icon != null:
#		custom_right = small_icon # texture for output connector

	var slotID = newNode.get_position_in_parent()
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
	
	var prodTimer = $TopDisplay/InfoVBox/ProductionTimer
	var prodClock = $TopDisplay/InfoVBox/HBoxContainer/ProductionProgressClock
	if not prodTimer.is_stopped():
		prodClock.value = prodTimer.time_left / prodTimer.get_wait_time()


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


func spawn_product():
	emit_signal("product_ready", product)
	$TopDisplay/InfoVBox/ProductionTimer.stop()
	produced_this_burst += 1
	if produced_this_burst >= burst_size:
		$TopDisplay/InfoVBox/RestTimer.start()
		produced_this_burst = 0
	else:
		$TopDisplay/InfoVBox/ProductionTimer.start()
	
	$TopDisplay/InfoVBox/AudioStreamPlayer2D.play()
		

func requirements_met():
	if requirements.size() == 0:
		# if the output is for "cash": deduct money from Global.player.cash
		if product_name == "cash":
			Global.player.cash -= 1

		return true

	for requirement in requirements:
		if get_commodity_count(requirement) < requirements.count(requirement):
			return false
	return true

func _on_ProductionTimer_timeout():
	if requirements_met():
		spawn_product()
	
func get_commodity_count(commodityName):
	return buffer.count(commodityName)
	
func _on_commodity_received(commodityName):
	if buffer.size() < buffer_size:
		buffer.push_back(commodityName)



func _on_RestTimer_timeout():
	$TopDisplay/InfoVBox/ProductionTimer.start()
	$TopDisplay/InfoVBox/RestTimer.stop()


#func _on_InfoButton_toggled(button_pressed):
#	find_node("PopupInfoDialog").popup()
#
#
#func _on_PopupInfoDialog_popup_hide():
#	$TopDisplay/InfoVBox/Position2D/InfoButton.pressed = false
#


func _on_InfoButton_pressed():
	var popupDialog = find_node("PopupInfoDialog")
	popupDialog.window_title = title + " " + short_desc
	popupDialog.find_node("LongDescLabel").text = long_desc
	popupDialog.popup()


func _on_HustleGraphNode_close_request():
	# confirm, then remove connections
	# send the card back to your hand?
	
	# or, just roll it up a little?
	var boxToToggle = $TopDisplay/InfoVBox
	if boxToToggle.visible == true:
		prev_rect_size = rect_size

	boxToToggle.visible = !boxToToggle.visible
	
	if boxToToggle.visible == false:
		rect_size = rect_min_size
		resizable = false
	else:
		rect_size = prev_rect_size
		resizable = true
	
	
	
	pass # Replace with function body.
