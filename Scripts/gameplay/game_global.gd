extends Node

# explanation of the simple pattern we're using here:
# https://www.youtube.com/watch?v=fA6jSAaVCbE
# keep in mind this approach is only suitable where:
# -there's always exactly and only 1 instance of something
# -it's something many other places in code will need to use

enum EnemyTypes{ROBODOG, DOGELISK, ANDROID, TURRET, ROOMBYE, FLOATING_HEAD, QUADCOPTER}

var player_ref: Player
var world_boundaries: WorldBoundaries

signal add_score(new_score: int)
signal score_changed(new_score: int)
signal combo_changed(new_combo: int)
signal game_over
signal final_score(score: int)
signal enemy_killed
