extends Node

# Common steering behavior for enemies.

onready var player_controller = get_node("/root/player_controller")
onready var steering = get_node("/root/steering")

func seek_player(enemy):
	var player = player_controller.player
	var steer = steering.pursue(enemy.global_position, player.global_position, \
			enemy.current_motion, player.current_motion, enemy.SPEED, player.SPEED)
	return steering.steer(steer, enemy.current_motion, enemy.SPEED, enemy.STEERING_FORCE, enemy.MASS)