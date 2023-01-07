"""
Basic graph where users connect nodes to each other
and assign labour resources from their deck to accelerate throughput
(like socketing gems)

"""

extends GraphEdit


var hustle_graph_node = load("res://GraphNetwork/HustleGraphNode.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_low_processor_usage_mode(true)

	add_valid_connection_type(0,0)
	Global.hustle_graph = self
	
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
	
	connect_node(from, from_slot, to, to_slot)


func _on_HustleGraph_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)

func _on_resource_dropped(graphNode : GraphNode):
	if graphNode == null:
		printerr("HustleGraph didn't get a graphNode")
	else:
		spawn_node(graphNode)
	
