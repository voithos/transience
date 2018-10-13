extends "res://scripts/base_scripts/enemy.gd"

# TODO: Adjust jumper steering params.

func _ready():
	pass

func _physics_process(delta):
	if current_ai_state == AI_STATE_BATTLE:
		steering.wander()
		var motion = steering.steer()
		move_entity(motion, 'down', delta)