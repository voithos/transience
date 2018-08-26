extends Node

# Common steering behavior for enemies.

onready var player_controller = get_node("/root/player_controller")
onready var steering = get_node("/root/steering")

func seek_player(enemy):
	var ret = steering.wander(enemy.global_position, 100, 100, enemy.wander_angle, .5, \
			enemy.current_motion)
	enemy.wander_angle = ret[1]
	return steering.steer(ret[0], enemy.current_motion, enemy.SPEED / 3, enemy.STEERING_FORCE, enemy.MASS)