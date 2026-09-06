class_name LoadingScreen extends CanvasLayer

var scene_path: String
var process_tick_count := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if scene_path == "":
		push_warning("Could not queue up scene %s" % scene_path)
		return
	ResourceLoader.load_threaded_request(scene_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(scene_path)
	print(status)
	match status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			invalid_resource()
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			failed()
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			in_progress()
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			loaded()


func invalid_resource() -> void:
	push_error("Loading Screen ThreadLoad invalid resource: %" % scene_path)
	queue_free()


func failed() -> void:
	push_error("Loading Screen ThreadLoad failed: %" % scene_path)
	queue_free()


func in_progress() -> void:
	process_tick_count += 1
	if process_tick_count % 600 == 0:
		print("loading %s for %s process ticks" % [scene_path, process_tick_count])


func loaded() -> void:
	print(">>> loaded %s after %s process ticks" % [scene_path, process_tick_count])
	var new_scene = ResourceLoader.load_threaded_get(scene_path).instantiate()
	get_tree().change_scene_to_node(new_scene)
