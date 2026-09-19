class_name PrecompileTask

signal finished

var scene:PackedScene
var container:Node

func _init(in_scene:PackedScene, in_container:Node) -> void:
	scene = in_scene
	container = in_container
	
func run() -> Signal:
	print_debug("Precompiling %s ..." % [scene.resource_path])
	var start:int = Time.get_ticks_usec()
	
	var node:Node = scene.instantiate()
	container.add_child(node)
	
	var tree:SceneTree = Engine.get_main_loop()
		
	# If there are any particle node types then make sure they are emitting
	var particle_nodes:Array[Node] = Utils.down_tree_matching(node, func(n:Node) -> bool:
		return n is GPUParticles3D or n is CPUParticles3D or n is GPUParticles2D or n is CPUParticles2D
	)
	
	if particle_nodes:
		await tree.process_frame
		for particle_node in particle_nodes:
			if not particle_node.emitting:
				particle_node.restart()
				particle_node.emitting = true
		await tree.create_timer(1.0).timeout
	
	# Look first for method then for metadata key
	var wait_time:float = 0.0
	if node.has_method("get_precompilation_wait_time"):
		wait_time = node.get_precompilation_wait_time()
	else:
		wait_time = node.get_meta("precompilation_wait_time", 0.0)
		
	if wait_time > 0:
		await tree.create_timer(wait_time).timeout
			
	await tree.process_frame
	await tree.process_frame
	
	if is_instance_valid(node):
		node.queue_free()
	
	var end:int = Time.get_ticks_usec()
	print_debug("Precompiled %s in %.1fms" % [scene.resource_path, (end - start) / 1000.0])

	finished.emit()
	
	return finished
