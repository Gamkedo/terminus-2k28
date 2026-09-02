# Randomly place scenery around the world. Intended for arcade mode.
#  To add new scenery, create a SceneryItem resource in Scenes - Objects/Scenery.
#  Then drag into SceneryPlacer.SceneryList in the inspector.
#  Scenery can be made with either a sprite, or be made to spawn premade scenes. a SceneryItem resource must be created either way.

extends Node

## How spaced out to spawn items.
@export var tile_size: float = 2
## List of scenery items to be placed. Create a "SceneryItem" resource in Scenery - Objects/Scenery and drag it into the array
@export var scenery_list: Array[SceneryItem]
## Chance to spawn any scenery per tile
@export var base_spawn_chance: float = 0.2
## Scene reference for generic scenery items (created with just sprite)
@export var scenery_item_scene: PackedScene = null
## How far from edges to go before we can spawn scenery - removes this much from each edge
@export var border_size: float = 1

var total_chance: float = 0.0

func _ready() -> void:
	# calculate total chance number from scenery item list
	for res in scenery_list:
		total_chance += res.spawn_chance
	
	# Spawn random scenery within the bounds of the game world
	var bounds = GameGlobal.world_boundaries.get_world_limits()
	for z in range(bounds["-z"] + border_size + tile_size, bounds["+z"] - border_size, tile_size):
		for x in range(bounds["-x"] + border_size + tile_size, bounds["+x"] - border_size, tile_size):
			if randf() < base_spawn_chance:
				try_create_rand_scenery_item(x, z)

func try_create_rand_scenery_item(x_coord: float, z_coord: float) -> void:
	# Choose random scenery to spawn
	
	# weighted chance picking from list
	var cur_chance: float = 0.0
	var choice = randf_range(0.0, total_chance)
	var scenery_res: SceneryItem = null
	for res in scenery_list:
		if choice < cur_chance + res.spawn_chance:
			scenery_res = res
			break
		cur_chance += res.spawn_chance
	
	if not scenery_res:
		print("Failed to randomly choose scenery item! This is an error with the code logic. No scenery will be spawned.")
		return
	
	# Setup scenery - spawn prefab if applicable, or setup sprite with parameters
	var scenery: Node = null
	if scenery_res.sprite:
		scenery = scenery_item_scene.instantiate()
		var scenery_sprite = (scenery.get_child(0) as Sprite3D)
		scenery_sprite.texture = scenery_res.sprite
		scenery_sprite.pixel_size = scenery_res.spr_pixel_size
		(scenery_sprite as Node3D).position.y += (scenery_sprite.texture.get_size().y * scenery_sprite.pixel_size) / 2
	elif scenery_res.scene:
		scenery = scenery_res.scene.instantiate()
	else:
		print("Scenery resources must have either sprite or scene assigned! " + scenery_res.resource_path)
	
	# If chosen scenery is valid, spawn it in
	if scenery:
		get_tree().current_scene.add_child.call_deferred(scenery)
		scenery.set_deferred("global_position", Vector3(x_coord, 0, z_coord))
		scenery.scale *= randf_range(scenery_res.scale_min, scenery_res.scale_max)
