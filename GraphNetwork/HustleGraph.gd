"""
Basic graph where users connect nodes to each other
and assign labour resources from their deck to accelerate throughput
(like socketing gems)

"""

extends GraphEdit


var hustle_graph_node = load("res://GraphNetwork/HustleGraphNode.tscn")
const port_grab_distance_horizontal = 48
const port_grab_distance_vertical = 48

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_low_processor_usage_mode(true)

	add_valid_connection_type(0,0)
	Global.hustle_graph = self
	
	$Panel.popup_centered()
	
	update()
	
func spawn_node(graphNode : GraphNode):
	
	add_child(graphNode)
	graphNode.set_offset(scroll_offset + get_local_mouse_position())
	graphNode.set_visible(true)
	graphNode.activate()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HustleGraph_connection_request(from, from_slot, to, to_slot):
	
	var err = connect_node(from, from_slot, to, to_slot)
	if err != OK:
		printerr(self.name + " HustleGraph.gd, error connecting signal " + str(err))

func _on_HustleGraph_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)

func _on_resource_dropped(graphNode : GraphNode):
	if graphNode == null:
		printerr("HustleGraph didn't get a graphNode")
	else:
		spawn_node(graphNode)
	
