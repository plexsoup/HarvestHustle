extends Node


var deck = []


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.card_database = self
	create_deck()
	

func create_deck():
	
	for resourceCardName in $ResourcePreloader.get_resource_list():
		deck.push_back(resourceCardName)
	deck.shuffle()

func draw_card():
	if deck.size() > 0:
		var newCardName = deck.pop_back()
		var newCard = $ResourcePreloader.get_resource(newCardName)
		return newCard.instance()
	else:
		create_deck()
		draw_card()
