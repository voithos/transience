extends "res://scripts/entity.gd"

# Base script for all enemy types.

# The distance that the char has to be from the enemy in order to trigger battle.
export (int) var TRIGGER_DISTANCE = 100
var TRIGGER_DISTANCE_SQUARED

const AI_STATE_IDLE = "IDLE"
const AI_STATE_BATTLE = "BATTLE"

var current_ai_state = AI_STATE_IDLE

func _ready():
	# Cache the square since sqrt() operations are slow.
	TRIGGER_DISTANCE_SQUARED = TRIGGER_DISTANCE * TRIGGER_DISTANCE
	add_to_group("enemies")

# Initiates a battle with an enemy.
func start_battle():
	current_ai_state = AI_STATE_BATTLE