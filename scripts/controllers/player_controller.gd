extends Node

# A controller that makes the player globally accessible.

var player

func set_player(player):
	self.player = player

func get_player_pos():
	return player.global_position

func get_player_dir():
	return player.get_dir()

func get_player_speed():
	return player.SPEED

func get_player_motion():
	return player.current_motion

func is_in_throwback():
	return player.current_state == player.STATE_THROWBACK