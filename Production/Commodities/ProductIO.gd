"""
A product stores the name and textures for a commodity

Product should be added to a graphNode to create a slot
then it can be received or produced by that same slot

Later we might make a version which spawns a sprite

"""

extends MarginContainer


export var product_name : String
export var product_icon : Texture
export var product_graphic : Texture
export (CommodityDatabase.Commodities) var product_type : int

var quantity_held : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/ProductName.text = product_name
	

func receive_product(amount):
	quantity_held += amount

func give_product(amount):
	if quantity_held >= amount:
		quantity_held -= amount
	else:
		return false # insufficient quantity
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass