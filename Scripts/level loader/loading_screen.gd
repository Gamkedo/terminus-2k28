class_name LoadingScreen extends CanvasLayer

var scene_path: String
var process_tick_count := 0
var process_time_count := 0.0
var time_at_last_tick := 0.0

var default_estimate := 100
var scene_load_estimates = {
	"uid://divrqdtp7jrcr" : 149,
}
var estimate := 400

@onready var progress_bar: ProgressBar = %ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if scene_path == "":
		push_warning("Could not queue up scene %s" % scene_path)
		return
	ResourceLoader.load_threaded_request(scene_path)
	estimate = get_load_estimate()
	time_at_last_tick = Time.get_ticks_msec()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(scene_path)
	#print(status)
	process_time_count += Time.get_ticks_msec() - time_at_last_tick
	time_at_last_tick = Time.get_ticks_msec()
	var percent_value = clampf(process_time_count / estimate , 0.0, 1.0)
	printt(percent_value, process_time_count, estimate)
	progress_bar.value = percent_value
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


func loaded() -> void:
	print(">>> loaded %s after %s process ticks and %s milliseconds" % [scene_path, process_tick_count, process_time_count])
	var new_scene = ResourceLoader.load_threaded_get(scene_path).instantiate()
	get_tree().change_scene_to_node(new_scene)


func get_load_estimate() -> float:
	if scene_load_estimates.has(scene_path):
		return scene_load_estimates[scene_path]
	else:
		return default_estimate
