"""
Commodity Convertors are added to GraphNodes
They have rest timers and production timers
They can serve as generators or receivers
They can take or add resources from/to the HustleGraphNode buffer

"""

extends Control

enum States { READY, RESTING, DISABLED }
var State = States.DISABLED

var graph_node



export var product : PackedScene
export var product_name : String
export var conversion_desc : String

# produce on 3, 3.5, 4
export var rest_beats : float = 2.5
export var production_beats : float = 0.5
export var burst_size : int = 3

var rest_interval : float = Global.spb * rest_beats
var unit_production_time : float = Global.spb * production_beats

export var requirements1 : PackedScene
export var requirements2 : PackedScene
export var requirements3 : PackedScene
var requirements = [requirements1, requirements2, requirements3]
export var num_required = [1, 0, 0]



signal product_ready(prod)


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var timer = get_tree().create_timer(0.25)
	yield(timer, "timeout")
	var err = connect("product_ready", Global.spawner, "_on_spawn_requested")
	if err != OK:
		printerr("CommodityConnector.gd error connecting signal in ready()")

	graph_node = get_parent()
	
	$VBox/HBoxContainer/ConversionDesc.text = conversion_desc

	$VBox/ProductionTimer.set_wait_time(unit_production_time)
	$VBox/RestTimer.set_wait_time(rest_interval)


func activate():
	$VBox/ProductionTimer.start()
	State = States.READY
	
	
	
func get_product_name():
	var referenceProduct = product.instance()
	var myName = referenceProduct.name.get_slice("@",0) # grab anything up to @
	referenceProduct.queue_free()
	print(myName)
	return myName
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if State != States.READY:
		return

	if $VBox/ProductionTimer.is_stopped() == false:
		var percent_complete = $VBox/ProductionTimer.time_left / $VBox/ProductionTimer.wait_time
		$VBox/HBoxContainer/ProductionProgress.value = percent_complete


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
	if requirements_met():
		deduct_requirements()
		
		spawn_product()
	find_node("RestTimer").start()
	



func _on_RestTimer_timeout():
	if State == States.RESTING:
		State = States.READY
		$VBox/ProductionTimer.start()

