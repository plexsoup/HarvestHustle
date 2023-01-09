tool
extends VBoxContainer

export var resource_image : Texture setget set_image
export var resource_name : String setget set_name
#export (String, MULTILINE) var description : String

#var production_schedule = load("res://Production/ProductionSchedule.tres").duplicate()

enum Categories { SUPPLIER, PRODUCTION, CUSTOMER, ACCELERATOR, LIMITER, SHIPPING, PACKAGING }
export (Categories) var resource_category = Categories.SUPPLIER setget set_category

export var price = 100
export var short_desc = ""
export (String, MULTILINE) var long_desc = ""

export var production_beats : float = 0.5
export var burst_size : int = 3
export var rest_beats : float = 2.5

export var tone : AudioStream

var production_delay = Global.spb * production_beats
var rest_delay = Global.spb * rest_beats


enum States { FORSALE, READY, DRAGGING, DROPPED }
var State = States.READY

var owned = false

#signal resource_dropped(resource, location)

func _get_configuration_warning():
	if $Processing/Inputs.get_child_count() < 1 or $Processing/Outputs.get_child_count() < 1:
		return "Add product nodes as children of Inputs and Outputs"
	else:
		return ""


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return
	
	if resource_name != null:
		$ResourceNameLabel.text = resource_name
	
	if resource_category != null:
		$ResourceCategoryLabel.text = Categories.keys()[resource_category].capitalize()

	$Pricetag.text = "$" + str(price) + ".00"
	$HustleGraphNode.set_visible(false)

	setup_graph_node()

	#delayed_ready(0.25) # let parents initialize first


func delayed_ready(timeToWait):
	var timer = get_tree().create_timer(timeToWait)
	yield(timer, "timeout")
	pass
#	var err = connect("resource_dropped", Global.hustle_graph, "_on_resource_dropped")
#	if err != OK:
#		printerr(self.name + " ResourceCard.gd")
#		printerr(err)

	if resource_image != null:
		$ResourceImage.texture = resource_image
		$ResourceImage.show()

func setup_graph_node():
	var graphNode = $HustleGraphNode
	graphNode.resource_texture = resource_image
	graphNode.title = resource_name


	var outputNodes = $Processing/Outputs.get_children()
	graphNode.add_outputs(outputNodes)

	var inputNodes = $Processing/Inputs.get_children()
	graphNode.add_inputs(inputNodes)
	

	if outputNodes.size() > 0:
		graphNode.product_name = outputNodes[0].product_name
		graphNode.product = outputNodes[0].duplicate()

	graphNode.production_delay = production_delay
	graphNode.rest_delay = rest_delay
	graphNode.tone = tone
	graphNode.burst_size = burst_size
	
	graphNode.short_desc = short_desc
	graphNode.long_desc = long_desc
	
	custom_startup_behaviour()
	
	
func custom_startup_behaviour():
	pass
	
	



func set_name(myName):
	resource_name = myName
	$ResourceNameLabel.text = myName

func set_image(myImage):
	resource_image = myImage
	
	if find_node("ResourceImage"):
		$ResourceImage.texture = myImage
		$ResourceImage.show()
	
	var graphNode = find_node("HustleGraphNode")
	if graphNode:
		graphNode.resource_texture = resource_image
	
		

func set_category(myCategory):
	$ResourceCategoryLabel.text = Categories.keys()[myCategory].capitalize()
	resource_category = myCategory
	

func spawn_sprite():
	var newSprite = DraggableResourceSprite.new()
	newSprite.texture = resource_image
	newSprite.scale = Vector2.ONE * 0.1
	newSprite.set_graph_node($HustleGraphNode)

	# hot potato with this HustleGraphNode
	remove_child($HustleGraphNode)
	Global.hustle_graph.add_child(newSprite)

	


func _on_ResourceCard_gui_input(event):
	if State != States.READY:
		return
	
	if event is InputEventMouseButton and event.is_pressed() == true:
		if Global.player.cash >= price:
			Global.player.cash -= price
			# drag the card onto the stage
			spawn_sprite()
			queue_free()
			
		else:
			# play a sound and pop up an explanation
			print("Not enough cash")
		

