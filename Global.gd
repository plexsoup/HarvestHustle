extends Node

var current_level
var player
var spawner
var stage_manager
var hustle_graph
var audio_manager
var card_database
var paused : bool = false

var bpm : float = 75.0
var spb : float = 1.0/(bpm/60.0)

var portrait_image : Texture
var objective_image : Texture
var aptitude_image : Texture


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func is_paused():
	return paused


func updateTimers():
	for cardTimer in get_tree().get_nodes_in_group("Pauseable"):
		cardTimer.set_paused(paused)

func pause():
	paused = true
	updateTimers()
	
func resume():
	paused = false
	updateTimers()

func toggle_pause():
	paused = !paused
	updateTimers()
