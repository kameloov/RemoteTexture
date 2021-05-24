tool
extends Node
class_name RemoteLoader

export var cache_folder = "user://remote_resources/";
export var autoload = false;
onready var http  = HTTPRequest.new();

func _ready():
	if not autoload:
		return 
	var textures = fetch_remote_textures()
	for t in textures:
		load_texture(t)
	
	
func fetch_remote_textures():
	var collection = []
	var path = get_tree().current_scene.filename
	var scene: PackedScene = load(path);
	for r in scene._bundled.variants:
		if r is ImageTexture and "url" in r :
			collection.append(r)
	return collection

func texture_from_url(url)->RemoteTexture:
	var texture = RemoteTexture.new()
	texture.url = url 
	load_texture(texture)
	return texture

func load_texture(resource : RemoteTexture):
	if resource.url == null or resource.url == "":
		printerr("Error loading texture, no url provided")
		return
	var task = LoadTask.new(resource,cache_folder)
	add_child(task)
	task.loadTexture()
