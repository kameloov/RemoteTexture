extends Node2D

var url = "https://cdn.pixabay.com/photo/2015/10/01/17/17/car-967387_960_720.png"

# Called when the node enters the scene tree for the first time.
func _ready():
	load_texture()


func load_texture():
	$Sprite.texture = $RemoteLoader.texture_from_url(url)
	pass
