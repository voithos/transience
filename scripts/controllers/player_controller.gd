extends Node

# A controller that makes the player globally accessible.

var player

func set_player(player):
	self.player = player

func get_player_pos():
	return player.global_position

func get_player_dir():
	return player.get_dir()
	
func is_in_throwback():
	return player.current_state == player.STATE_THROWBACK