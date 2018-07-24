extends Node

# Common steering behavior for enemies.

onready var player_controller = get_node("/root/player_controller")
onready var steering = get_node("/root/steering")

func seek_player(enemy):
	return steering.seek(enemy.global_position, player_controller.get_player_pos(), \
			enemy.SPEED, enemy.current_motion, enemy.STEERING_FORCE, enemy.MASS)