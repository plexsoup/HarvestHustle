"""
Basic graph where users connect nodes to each other
and assign labour resources from their deck to accelerate throughput
(like socketing gems)

"""

extends GraphEdit


var hustle_graph_node = load("res://GraphNetwork/HustleGraphNode.tscn")
const port_grab_distance_horizontal = 48
const port_grab_distance_vertical = 48

var scroll_speed : float = 50.0

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_low_processor_usage_mode(true)

	add_valid_connection_type(0,0)
	Global.hustle_graph = self
	
	$InstructionsPanel.popup_centered()
	
	update()
	
func spawn_node(graphNode : GraphNode):
	
	add_child(graphNode)
	graphNode.set_offset(scroll_offset + get_local_mouse_position())
	graphNode.set_visible(true)
	graphNode.activate()


func spawn_product(_product : MarginContainer, _location):
	pass
	# let the nodes signal each other for gods sake


func spawn_popup_number(value):
	var popupText = load("res://GraphNetwork/PopupText.tscn").instance()
	popupText.set_text(str(value))
	popupText.position = get_local_mouse_position()
	add_child(popupText)
	if value < 0:
		popupText.set_modulate(Color.brown)
		popupText.popdown()
	else:
		popupText.set_modulate(Color.green)
		popupText.popup()
	

func zoom_map(zoomSpeed : float):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", zoom+zoomSpeed, 0.3)



func _unhandled_input(_event):
	var zoomSpeed = 0.25
	if Input.is_action_just_pressed("zoom_in"):
		zoom_map(zoomSpeed)
	if Input.is_action_just_pressed("zoom_out"):
		zoom_map(-zoomSpeed)


	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		scroll_map(direction)

		
func scroll_map(direction : Vector2):
	var dash = 1.0
	if Input.is_action_pressed("dash"):
		dash = 5.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scroll_offset", scroll_offset + (direction*scroll_speed*dash), 0.1)
	


func _on_HustleGraph_connection_request(from, from_slot, to, to_slot):
	#print("From: " + from + ", " + str(from_slot))
	#print("To: " + to + ", " + str(to_slot))
	
	var fromGraphNode = get_node(from)
	var toGraphNode = get_node(to)
	fromGraphNode.connect_output_to_customer(toGraphNode)
	Global.player.cash -= 50
	spawn_popup_number(-50)
	
	#fromGraphNode.connect("product_ready", toGraphNode, "_on_commodity_received")
	
	
	var err = connect_node(from, from_slot, to, to_slot)
	if err != OK:
		printerr(self.name + " HustleGraph.gd, error connecting signal " + str(err))

func _on_HustleGraph_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
	var fromGraphNode = get_node(from)
	var toGraphNode = get_node(to)
	fromGraphNode.disconnect_output_from_customer(toGraphNode)



func _on_resource_card_dropped(graphNode : GraphNode):
	if graphNode == null:
		printerr("HustleGraph didn't get a graphNode")
	else:
		spawn_node(graphNode)
	
func _on_product_spawned(_graphNode, product : MarginContainer):
	spawn_product(product, scroll_offset + get_local_mouse_position())

	# send a signal to the graphNode to tell it a new product has been spawned
	# teleport it directly there (for now)
	var destination = get_connection_list()[0].to_port
	var destination_position = destination.get_global_position()
	product.global_position = destination_position
	
