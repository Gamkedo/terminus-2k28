extends Node

# explanation of the simple pattern we're using here:
# https://www.youtube.com/watch?v=fA6jSAaVCbE
# keep in mind this approach is only suitable where:
# -there's always exactly and only 1 instance of something
# -it's something many other places in code will need to use

enum EnemyTypes{ROBODOG, DOGELISK, ANDROID, TURRET, ROOMBYE, FLOATING_HEAD, QUADCOPTER, SMART_DROID}

var player_ref: Player
var world_boundaries: WorldBoundaries

# tracking within play session for which rounds have been won, to show win text
# there are certainly nicer ways to do this but the game releases tomorrow, doing
# doing in a simple way that involves minimal complexity / mental overhead
var won_arc = false
var won_surv = false
var won_imm = false

signal add_score(new_score: int)
signal score_changed(new_score: int)
signal combo_changed(new_combo: int)
signal wave_changed(new_wave: int)
signal game_over
signal final_score(score: int)
signal enemy_killed

func _ready() -> void:
	LightningBolt.pregenerate_meshes()
