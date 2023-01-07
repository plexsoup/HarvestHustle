"""
Commodity Connectors are added to GraphNodes
They have rest timers and production timers
They can serve as generators or receivers
They can take or add resources from/to the HustleGraphNode buffer

"""

extends Control

enum States { READY, RESTING, DISABLED }
var State = States.READY

var graph_node

enum ConnectorTypes { GENERATOR, RECEIVER }
export (ConnectorTypes) var Type = ConnectorTypes.RECEIVER

export var product : PackedScene
var product_name : String


signal product_ready(prod)


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var timer = get_tree().create_timer(0.25)
	yield(timer, "timeout")
	var err = connect("product_ready", Global.spawner, "_on_spawn_requested")
	if err != OK:
		printerr("CommodityConnector.gd error connecting signal in ready()")

	graph_node = get_parent()
	find_node("ProductionTimer").start()
	
	if Type != ConnectorTypes.GENERATOR:
		$VBox/HBoxContainer/ProductionProgress.hide()

	product_name = get_product_name()
	
func get_product_name():
	var referenceProduct = product.instance()
	var myName = referenceProduct.name.get_slice("@",0) # grab anything up to @
	referenceProduct.queue_free()
	print(myName)
	return myName
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Type == ConnectorTypes.GENERATOR:
		if $VBox/ProductionTimer.is_stopped() == false:
			var percent_complete = $VBox/ProductionTimer.time_left / $VBox/ProductionTimer.wait_time
			$VBox/HBoxContainer/ProductionProgress.value = percent_complete
	elif Type == ConnectorTypes.RECEIVER and graph_node != null:
		$VBox/HBoxContainer/BufferValue.text = str(graph_node.get_commodity_count(product_name))


func spawn_product():
	# assumes requirements already met and deducted
	if product != null:
		var newProduct = product.instance()
		var min_dist = 15.0
		var max_dist = 50.0
		var spawnOffset = Vector2.RIGHT.rotated(randf()*TAU) * rand_range(min_dist,max_dist)
		var spawnPos = get_global_position() + rect_size + spawnOffset
		newProduct.set_global_position(spawnPos)
		#emit_signal("product_ready", newProduct)
		add_child(newProduct)
	else:
		printerr(self.name + " HustleGraphNode.gd, error in spawn_product. product is not defined.")

	State = States.RESTING
	find_node("RestTimer").start()
	

func requirements_met():
	return true

func deduct_requirements():
	pass

func _on_ProductionTimer_timeout():
	if Type == ConnectorTypes.GENERATOR:
		if requirements_met():
			deduct_requirements()
			
			spawn_product()
		find_node("RestTimer").start()
	



func _on_RestTimer_timeout():
	if State == States.RESTING:
		State = States.READY
		$VBox/ProductionTimer.start()

