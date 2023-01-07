"""
Handle scene siwtching and initializing new levels

"""


extends Control


var levels = {
	"DreamBoard":"res://DreamBoard/DreamBoard.tscn",
	"Game":"res://Levels/Level01.tscn",
}


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.stage_manager = self
	switch_scene("DreamBoard")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func switch_scene(sceneTitle):
	for child in $CurrentLevel.get_children():
		child.queue_free()
	var nextLevel = load(levels[sceneTitle]).instance()
	$CurrentLevel.add_child(nextLevel)
	
