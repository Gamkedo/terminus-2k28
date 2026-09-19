class_name Precompilation3D extends Node3D

@export
var precompilation_group_name:String = "Precompilation"

@export
var max_concurrency:int = 3


## Keep precompiled resources alive so the shaders are not released after the loading screen
static var _PRECOMPILED_SCENES:Array[PackedScene]

#region Signals
signal started(total_count:int)
signal progress_changed(progress:float, count:int)
signal completed
#endregion

# These should already be excluded from packaged game but also doing locally to avoid
# unnecessary deep traversals
@export 
var excluded_dirs:PackedStringArray = [
	"/addons/",
	"/demo/",
	"/build/",
	"/examples/",
	"/test/"
]

@onready var container: Node3D = %Scenes
		
func run() -> void:
	if not visible: 
		show()
	await get_tree().process_frame

	var start:int = Time.get_ticks_usec()
	await _precompile_scenes()
	var end:int = Time.get_ticks_usec()
	
	print_debug("%s: Precompilation completed in %.1fms" % [name, (end - start) / 1000.0])
	
func _precompile_scenes() -> Signal:
	var scenes:Array[PackedScene] = _get_tagged_scenes()
	_PRECOMPILED_SCENES = scenes
	
	started.emit(scenes.size())
	
	# Special case where there are no scenes to precompile
	if not scenes:
		completed.emit.call_deferred()
		return completed
		
	var concurrency_count:PackedInt32Array = [0]
	var completed_count:PackedInt32Array = [0]
	var task_queue:Array[PrecompileTask]
	var running_tasks:Array[PrecompileTask]
	
	var run_task := func(task:PrecompileTask) -> void:
		concurrency_count[0] += 1
		@warning_ignore("missing_await")
		task.run()
		
	for i in scenes.size():
		var scene := scenes[i]
		# Could process in batches since task returns a signal that can later be awaited
		# Though the compilation process is going to be serial anyways
		var precompile_task := PrecompileTask.new(scene, container)
		# Keep it from getting destroyed before it finishing running
		running_tasks.push_back(precompile_task)
		
		precompile_task.finished.connect(func() -> void:
			completed_count[0] += 1
			concurrency_count[0] -= 1
			running_tasks.erase(precompile_task)
			
			var completed_fraction:float = float(completed_count[0]) / scenes.size()
			progress_changed.emit(completed_fraction, 1)
			if task_queue:
				run_task.call(task_queue.pop_back())
			elif completed_count[0] == scenes.size():
				completed.emit()
		)
		
		if concurrency_count[0] < max_concurrency:
			run_task.call(precompile_task)
		else:
			task_queue.push_back(precompile_task)
	return completed
	
func _get_tagged_scenes() -> Array[PackedScene]:
	var tagged_scenes:Array[PackedScene]
	
	var all_scene_files:PackedStringArray = _get_all_scene_files()
	print_debug("%s: Discovered %d scene files" % [name, all_scene_files.size()])
	
	for scene_file in all_scene_files:
		var scene:PackedScene = ResourceLoader.load(scene_file, "PackedScene") as PackedScene
		if not scene:
			push_warning("%s: Could not load PackedScene from resource path %s" % [name, scene_file])
			continue
		if Utils.scene_has_group(scene, precompilation_group_name, true):
			tagged_scenes.push_back(scene)
	
	print_debug("%s: Found %d scenes tagged with %s" % [name, tagged_scenes.size(), precompilation_group_name])	
	return tagged_scenes
		
func _get_all_scene_files() -> PackedStringArray:
	var scene_files:PackedStringArray
	var stack:Array[String]
	
	stack.push_back("res://")
	
	while stack:
		var dir:String = stack.pop_back()
		var dir_resources: PackedStringArray = ResourceLoader.list_directory(dir)
		for file in dir_resources:
			if file.ends_with(".tscn"):
				var full_path := dir + file
				scene_files.push_back(full_path)
			# Exclude dot directories like .godot and .assets by default - these won't be in the packaged game
			elif file.ends_with("/") and not file.begins_with("."):
				var full_path := dir + file
				# Make sure not in exclusion list
				var include:bool = true
				for exclusion in excluded_dirs:
					if full_path.contains(exclusion):
						include = false
						break
				if include:
					stack.push_back(full_path)
	return scene_files
