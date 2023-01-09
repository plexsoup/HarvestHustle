class_name DraggableResourceSprite

extends Sprite

var hustle_graph_node : GraphNode

enum States { DRAGGING, DROPPED }
var State = States.DRAGGING

signal sprite_dropped()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var _err = connect("sprite_dropped", Global.hustle_graph, "_on_resource_dropped")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("click"):
		position = Global.hustle_graph.get_local_mouse_position()
	else:
		switch_to_node()
		
func switch_to_node():
	# hot potato with this HustleGraphNode
	emit_signal("sprite_dropped", hustle_graph_node)
	queue_free()

func set_graph_node(graphNode):
	hustle_graph_node = graphNode
	
