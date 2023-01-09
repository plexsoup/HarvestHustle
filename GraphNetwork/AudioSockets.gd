extends GridContainer


var graph_node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(myGraphNode):
	graph_node = myGraphNode
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SlowDown_toggled(button_pressed):
	if button_pressed:
		graph_node.adjust_tempo(-1)
	else:
		graph_node.adjust_tempo(1)


func _on_PitchDown_toggled(button_pressed):
	if button_pressed:
		graph_node.adjust_pitch(-1)
	else:
		graph_node.adjust_pitch(1)


func _on_PitchUp_toggled(button_pressed):
	if button_pressed:
		graph_node.adjust_pitch(1)
	else:
		graph_node.adjust_pitch(-1)



func _on_SpeedUp_toggled(button_pressed):
	if button_pressed:
		graph_node.adjust_tempo(1)
	else:
		graph_node.adjust_tempo(-1)
