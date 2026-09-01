extends Control

@onready var scoreLabel: Label = %ScoreLabel
@onready var comboLabel: Label = %ComboLabel

var score: int = 0;
var combo: int = 0;

func addScore(addThisNumber:int) -> void:
	score += addThisNumber
	scoreLabel.text = "SCORE: " + str(score).pad_zeros(6)

func setScore(toThisNumber:int) -> void:
	score = toThisNumber
	scoreLabel.text = "SCORE: " + str(score).pad_zeros(6)

func setCombo(toThisNumber:int) -> void:
	combo = toThisNumber
	if combo==0: 
		comboLabel.text = ""
	else: 
		comboLabel.text = "x" + str(combo) + " COMBO"

func _ready() -> void:
	setScore(0)
	setCombo(0)
	# listen for the signals sent from enemy.die()
	GameGlobal.add_score.connect(addScore)
	GameGlobal.score_changed.connect(setScore)
	GameGlobal.combo_changed.connect(setCombo)
	pass

func _process(delta: float) -> void:
	# TODO:
	# - maybe animate the score going up one by one here?
	# - use timestamps to determine combo expiry state
	# - listen for player hit/die signals to reset combo
	pass
