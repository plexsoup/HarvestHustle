
extends Resource

export var rest_beats : float = 2.5
export var production_beats : float = 0.5
export var burst_size : int = 3
export var product : PackedScene = load("res://Objects/Product.tscn")
export var requirements = {
	"cash":5,
}
