tool
extends HTTPRequest
class_name LoadTask

var resource : RemoteTexture
var cache_folder = ""

func _init(res: RemoteTexture, folder):
	cache_folder = folder
	resource = res;
	
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("request_completed",self,"_completed")


func loadTexture():
	if resource.loadPriority == RemoteTexture.LoadStrategy.DISK_FIRST : 
		load_from_disk();
	elif resource.loadPriority == RemoteTexture.LoadStrategy.REMOTE_FIRST : 
		load_from_url();
		
func load_from_disk():
	print("loading from disk")
	var paths = [];
	var temp_file:File = File.new()
	if resource.type == RemoteTexture.ImageType.AUTO_DETECT:
		var basename =cache_folder+ generate_file_name();
		paths.append(basename+'png')
		paths.append(basename+'jpg')
		paths.append(basename+'jpeg')
		paths.append(basename+'bmp')
		
	else :
		paths.append(cache_folder+generate_file_name());
	var img = Image.new();
	var loaded = null; 
	for path in paths:
		if not temp_file.file_exists(path):
			continue
		loaded = img.load(path);
		if loaded == OK: 
			resource.create_from_image(img)
			break;
			
	if loaded != OK :
		match resource.loadPriority:
			RemoteTexture.LoadStrategy.DISK_FIRST : load_from_url();
			RemoteTexture.LoadStrategy.REMOTE_FIRST : printerr("error couldn't load texture from any source");

func load_from_url():
	print("loading from url")
	if resource.url=="":
		printerr("url is not valid : %s"%self.url);
	else :
		request(resource.url);

func generate_file_name(extention=""):
	var fname = resource.url.sha1_text();
	match resource.type :
		RemoteTexture.ImageType.PNG : fname +=".png";
		RemoteTexture.ImageType.JPG : fname +=".jpg"
		RemoteTexture.ImageType.AUTO_DETECT : fname += '.'+extention;
	return fname;

func check_dir():
	var dir = Directory.new();
	if not dir.dir_exists(cache_folder):
		dir.make_dir(cache_folder);
	
func save_image(data,extention =""):
	check_dir();
	var file = File.new();
	var path = cache_folder+generate_file_name(extention);
	file.open(path, File.WRITE);
	file.store_buffer(data);
	file.close();


func find_extention(source:String):
	var s = source.split(":")[1].strip_edges();
	return s.trim_prefix("image/");
	
func _completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		var extention = "";
		for h in headers:
			if h.to_lower().begins_with("content-type"):
				extention = find_extention(h);
		save_image(body,extention);
		load_from_disk();
	else :
		match resource.loadPriority:
			RemoteTexture.LoadStrategy.REMOTE_FIRST : load_from_disk();
			RemoteTexture.LoadStrategy.DISK_FIRST : printerr("error couldn't load texture from any source"); 


