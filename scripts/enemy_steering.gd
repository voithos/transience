extends Node

# Common steering behavior for enemies.

onready var player_controller = get_node("/root/player_controller")
onready var steering = get_node("/root/steering")

func seek_player(enemy):
	var steer = steering.pursue(enemy.global_position, player_controller.get_player_pos(), \
			enemy.current_motion, player_controller.get_player_motion(), enemy.SPEED, player_controller.get_player_speed())
	return steering.steer(steer, enemy.current_motion, enemy.SPEED, enemy.STEERING_FORCE, enemy.MASS)