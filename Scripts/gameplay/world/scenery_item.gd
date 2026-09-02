extends Resource

class_name SceneryItem

## Sprite for scenery item
@export var sprite: CompressedTexture2D = null
## Change pixel size of sprite reference
@export var spr_pixel_size := 0.05
## Or just spawn a custom scene - this can be empty
@export var scene: PackedScene = null
## Chance to spawn this among others. I'm using 1 as the "default" so make it higher or lower than 1 to change likelihood of spawning.
@export var spawn_chance: float = 1.0
## minimum amount to scale scene by
@export var scale_min: float = 1.0
## maximum amount to scale scene by
@export var scale_max: float = 1.0
