class_name EnemyBatch extends Resource

enum EnemyTypes{ROBODOG, DOGELISK}

@export var enemy_type : EnemyTypes ## The enemy type to spawn.
@export var spawn_amount : int ## The number of enemies of this time to spawn.
