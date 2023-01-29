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




enum States { INITIALIZING, WAITING_FOR_PULSE, READY, MOVING, RESIZING, DISABLED }
var State = States.READY

var buffer_size = 10
var buffer = [] # push and pop product commodity names as required


export var resource_texture : Texture setget set_resource_texture
var product : MarginContainer
var product_name : String

var requirements = [] # list of Commodity names required to produce product
var outputs = [] # list of Commodity names produced by this node
var output_slots = []

var connected_customers = [] # list of nodes that are connected to this node's output slots
var connected_suppliers = [] # list of nodes that are connected to this node's input slots
var custom_outputs = [] # list of custom output slots currently connected

var production_delay setget set_production_delay
var rest_delay setget set_rest_delay
var default_rest_delay
var default_production_delay


var burst_size : int
var produced_this_burst : int = 0

var tone : AudioStream setget set_tone
var pitch_scale = [1.0, 1.122, 1.189, 1.335, 1.498, 1.682, 1.89]
var pitch_sequence = [] # generate a string of 32 notes we can loop through
var current_pitch_selection_index : int = 0
var current_pitch_selection : int = 0

var pitch_factor = 1.0
var tempo_factor = 1.0


var short_desc setget set_short_desc
var long_desc setget set_long_desc

var prev_rect_size # for hiding the portrait picture


signal product_ready(prod)

# Called when the node enters the scene tree for the first time.
func _ready():
	$TopDisplay/InfoVBox/Sockets.init(self)

	set_resizable(true)
	if resource_texture != null:
		$TopDisplay/InfoVBox/ResourcePic.texture = resource_texture
		$CardDetailsPopup/PopupInfoDialog/PopupHbox/ResourcePic2.texture = resource_texture
	State = States.DISABLED

	generate_pitch_sequence()

# The graph doesn't care about our product signals
#	var err=connect("product_ready", Global.hustle_graph, "spawn_product")
#	if err != OK:
#		print("Error connecting to hustle_graph: ", err)

func generate_pitch_sequence():
	var length = ( randi()%8 + 1 ) * 4
	var last_index_value = 0
	var trendDirection = 1
	
	for i in range(length):
		pitch_sequence.push_back(last_index_value)
		last_index_value += ( randi()%3 - 1 ) * trendDirection
		last_index_value = last_index_value % pitch_scale.size()

		if i%4 == 0:
			if randf() < 0.33:
				trendDirection *= -1


func activate():
	if requirements.size() == 0:
		
		# connect to the pulse from audio_manager
		Global.audio_manager.subscribe_to_pulse_beat(self, "_on_pulse_beat")
		State = States.WAITING_FOR_PULSE
		
		
	else:
		State = States.READY
		#$TopDisplay/InfoVBox/RestTimer.start()


func set_short_desc(newShortDesc):
	short_desc = newShortDesc
	$TopDisplay/InfoVBox/HBoxContainer/ShortDescLabel.text = newShortDesc


func set_long_desc(newLongDesc : String):
	if newLongDesc != null:
		long_desc = newLongDesc
		find_node("LongDescLabel").text = newLongDesc

func set_production_delay(newDelay):
	if default_production_delay == null:
		default_production_delay = newDelay
	$TopDisplay/InfoVBox/ProductionTimer.set_wait_time(newDelay)

func set_rest_delay(newDelay):
	if default_rest_delay == null:
		default_rest_delay = newDelay
	$TopDisplay/InfoVBox/RestTimer.set_wait_time(newDelay)

func set_tone(newTone):
	$TopDisplay/InfoVBox/Audio/ProductionCompleteNoise.stream = newTone
	tone = newTone


func set_resource_texture(newTexture : Texture):
	resource_texture = newTexture
	$TopDisplay/InfoVBox/ResourcePic.texture = newTexture
	$CardDetailsPopup/PopupInfoDialog/PopupHbox/ResourcePic2.texture = newTexture
	
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


func add_slots(newSlots : Array, portType : String):
	for i in range(newSlots.size()):
		var newSlotNode = newSlots[i].duplicate()
		add_slot(newSlotNode, portType)


func add_slot(newNode, side:String):
	# the newNode to add should inherit from Product.tscn
	if side == "input":
		requirements.append(newNode.product_name)
	else:
		outputs.append(newNode.product_name)
		output_slots.append(newNode)
		

	add_child(newNode) # Important
	
	
	var enable_left : bool = side == "input"
	var enable_right : bool = side == "output"
	var type_left = 0
	var type_right = 0
	var color_left = Color.green
	var color_right = Color.green
	var custom_left = null
	var custom_right = null
	
	if "Bank" in newNode.name:
		print("Bank Deposits")
		
	if newNode.get("port_enabled") != null and newNode.port_enabled == false:
		enable_left = false
		enable_right = false
		if side == "output":
			connect_output_to_custom_code(newNode)
	
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
		resize_graph_node()

	update_production_timer()


func resize_graph_node():
	rect_size = get_local_mouse_position()
	if Input.is_action_pressed("resize_graphnode") == false:
		State = States.READY
	
	
func update_production_timer():
	var prodTimer = $TopDisplay/InfoVBox/ProductionTimer
	var prodClock = $TopDisplay/InfoVBox/HBoxContainer/ProductionProgressClock
	if not prodTimer.is_stopped():
		prodClock.value = prodTimer.time_left / prodTimer.get_wait_time()
	var restTimer = $TopDisplay/InfoVBox/RestTimer
	var restClock = $TopDisplay/InfoVBox/HBoxContainer/RestClock
	if not restTimer.is_stopped():
		restClock.value = restTimer.time_left / restTimer.get_wait_time()


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
	selected = false



func _on_HustleGraphNode_offset_changed():
	State = States.MOVING


func connect_output_to_customer(customerGraphNode):
	var err = connect("product_ready", customerGraphNode, "_on_commodity_received")
	if err == null or err == OK:
		connected_customers.append(customerGraphNode)
	else:
		printerr("HustleGraphNode.gd error connecting to customer: ", err)
	
func connect_output_to_custom_code(outputNode):
	var err = connect("product_ready", outputNode, "_on_commodity_received")
	if err == null or err == OK:
		custom_outputs.append(outputNode)
	else:
		printerr("HustleGraphNode.gd error connecting to custom output slot: ", err)
	
func disconnect_output_from_customer(customerGraphNode):
	disconnect("product_ready", customerGraphNode, "_on_commodity_received")
	connected_customers.erase(customerGraphNode)
	

func lightup_output_line_briefly():
	if output_slots.size() > 0:
		#set_slot_color_right(output_slot_ID, Color.yellow)
		var tween = get_tree().create_tween()
		tween.tween_method(self, "colorize_output_line", Color.yellow, Color.darkblue, 0.75)

func colorize_output_line(newColor):
	set_slot_color_right(output_slots[0].get_position_in_parent(), newColor)

func lightup_input_line_briefly(commodityName):
	var tween = get_tree().create_tween()
	tween.tween_method(self, "colorize_input_line", Color.yellow, Color.darkblue, 0.75, [commodityName])
	
	
func colorize_input_line(newColor, commodityName):
	var slotIdx = get_input_slot(commodityName)
	if slotIdx != null:
		set_slot_color_left(slotIdx, newColor)


func get_input_slot(commodityName): 
	# technical debt. We should already know the slot ID
	# this will fail if there's more than one input with the same commodity name
	# it also doesn't check if the slot is an input or output, so wouldn't work for throughput graphnodes
	
	for child in get_children():
		if child.get("product_name"):
			if child.product_name == commodityName:
				return child.get_position_in_parent()

	

func spawn_product_sprite():
	# spawn a sprite with a product icon
	var productSprite = load("res://Objects/GroundLitter/ProductLitter.tscn").instance()
	productSprite.get_node("Sprite").texture = product.product_icon
	add_child(productSprite)	
	productSprite.visible = true
	var offset = 35
	var randOffset = Vector2(rand_range(-offset, offset), rand_range(-offset, offset))
	
	productSprite.position = rect_size + randOffset
	productSprite.product_name = output_slots[0].product_name
	#productSprite.scale = Vector2(1, 1) * 0.1
	#productSprite.rotation = 0
	#productSprite.z_index = 1
	#productSprite.modulate = Color.white


func spawn_product():
	# send a signal to connected customers
	# if there are no customers, send a signal to the custom output port
	# if there is no custom output port, spawn a sprite with a product icon

	produce_sound()
	resume_production_timers()

	if connected_customers.size() > 0: # graphnode is connected to a customer.
		# send a signal to the customer
		#var customer = connected_customers[0]
		#customer._on_commodity_received(product_name)
		emit_signal("product_ready", product_name)
		lightup_output_line_briefly()
	elif custom_outputs.size() > 0: #graphnode is connected to a custom output port.
		# send a signal to the custom output port
		#var customOutput = custom_outputs[0]
		#customOutput._on_commodity_received(product_name)
		emit_signal("product_ready", product_name)
	else: #graphnode is connected to nothing. Spawn a sprite.
		spawn_product_sprite()


func resume_production_timers():
	$TopDisplay/InfoVBox/ProductionTimer.stop()
	produced_this_burst += 1
	if produced_this_burst >= burst_size:
		$TopDisplay/InfoVBox/RestTimer.start()
		produced_this_burst = 0
	else:
		$TopDisplay/InfoVBox/ProductionTimer.start()


func adjust_pitch(dir):
	pitch_factor += 0.5 * dir
	
func adjust_tempo(dir):
	tempo_factor += 0.5 * dir

func produce_sound():
	if $TopDisplay/InfoVBox.visible:
		#var soundSystem = Global.audio_manager
		var audioPlayer = $TopDisplay/InfoVBox/Audio/ProductionCompleteNoise

		current_pitch_selection_index += 1

		# loop if you hit the end
		current_pitch_selection_index = current_pitch_selection_index % (pitch_sequence.size())
		
		var current_pitch_scale = pitch_scale[pitch_sequence[current_pitch_selection_index]] * pitch_factor
		
		audioPlayer.set_pitch_scale(current_pitch_scale)
		
		audioPlayer.play()


func requirements_met():
	if requirements.size() == 0:
		return true

	for requirement in requirements:
		if get_commodity_count(requirement) < requirements.count(requirement):
			return false
	return true

func _on_ProductionTimer_timeout():
	if requirements_met():
		spawn_product()
	
func get_commodity_count(commodityName : String):
	return buffer.count(commodityName)
	
func _on_commodity_received(commodityName : String):
	if buffer.size() < buffer_size:
		buffer.push_back(commodityName )
	
	lightup_input_line_briefly(commodityName)
	
	if State == States.READY and requirements_met():
		if $TopDisplay/InfoVBox/RestTimer.is_stopped() and $TopDisplay/InfoVBox/ProductionTimer.is_stopped():
			$TopDisplay/InfoVBox/ProductionTimer.start()


func _on_RestTimer_timeout():
	if State == States.READY:
		$TopDisplay/InfoVBox/ProductionTimer.start()
		$TopDisplay/InfoVBox/RestTimer.stop()
		set_rest_delay(default_rest_delay * 1/tempo_factor)
		set_production_delay(default_production_delay * 1/tempo_factor)



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
	
	
func _on_pulse_beat():
	if State == States.WAITING_FOR_PULSE:
		$TopDisplay/InfoVBox/RestTimer.start()
		State = States.READY
		Global.audio_manager.unsubscribe(self, "_on_pulse_beat")


func _on_EnableButton_toggled(button_pressed):
	if !button_pressed:
		State = States.DISABLED
	else:
		State = States.WAITING_FOR_PULSE
		Global.audio_manager.subscribe_to_pulse_beat(self, "_on_pulse_beat")

	


func _on_HustleGraphNode_gui_input(event):
	if Input.is_action_just_pressed("ui_select"):
		if Input.is_class("InputEventMouseButton"):
			if event.is_doubleclick():
				print("double click")


func _on_HustleGraphNode_raise_request():
	if selected == false:
		$TopDisplay/InfoVBox/Audio/PickupCardNoise.play()
